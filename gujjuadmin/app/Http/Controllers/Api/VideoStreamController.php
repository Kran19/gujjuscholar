<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Video;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\URL;

class VideoStreamController extends Controller
{
    public function getStreamUrl(Request $request, $id)
    {
        $video = Video::findOrFail($id);
        
        $student = auth()->guard('api-student')->user();
        if (!$student) {
            return response()->json(['success' => false, 'message' => 'Unauthorized. Please login again.'], 401);
        }

        // Check if student has access
        $subject = $video->subject;
        $isSubjectFree = $subject ? ($subject->is_free ?? false) : false;
        $isCourseFree = ($subject && $subject->course) ? ($subject->course->is_free ?? false) : false;
        
        $isEnrolled = false;
        if ($student && $subject) {
            $isEnrolled = $student->enrollments()
                ->where(function($q) use ($subject) {
                    $q->where('subject_id', $subject->id)
                      ->orWhere('course_id', $subject->course_id);
                })
                ->where('status', 'active')
                ->exists();
        }

        // Allow playback if video is free, subject is free, course is free, or student is enrolled
        if (!$video->is_free && !$isSubjectFree && !$isCourseFree && !$isEnrolled) {
            return response()->json([
                'success' => false, 
                'message' => 'This is a premium video. Please enroll in this course or subject to watch.'
            ], 403);
        }

        $streamUrl = null;
        $rawHlsPath = $video->getRawOriginal('hls_path');
        $rawFilePath = $video->getRawOriginal('file_path');

        $resolvedHls = $this->resolveHlsPath($rawHlsPath);
        $resolvedFile = $this->resolveVideoFilePath($rawFilePath);

        // 1. If HLS processing completed and files exist, serve signed HLS
        if ($resolvedHls) {
            $streamUrl = URL::temporarySignedRoute(
                'video.stream.hls',
                now()->addHours(4),
                ['id' => $video->id]
            );
        }
        // 2. Otherwise fallback to direct local MP4 file streaming
        elseif ($resolvedFile) {
            $streamUrl = URL::temporarySignedRoute(
                'video.stream.direct',
                now()->addHours(4),
                ['id' => $video->id]
            );
        }
        // 3. Fallback to external/direct video URL or public storage
        elseif (!empty($video->video_url)) {
            $streamUrl = $video->video_url;
        } else {
            return response()->json([
                'success' => false,
                'message' => 'Video stream media is being prepared or file is not found.'
            ], 404);
        }

        $watermarkText = ($student->name ?? ($student->first_name . ' ' . $student->last_name)) . ' | ID: ' . $student->id;

        return response()->json([
            'success' => true,
            'data' => [
                'title' => $video->name,
                'stream_url' => $streamUrl,
                'duration' => $video->duration,
                'watermark_text' => $watermarkText,
            ]
        ]);
    }

    public function streamDirect(Request $request, $id)
    {
        if (!$request->hasValidSignature()) {
            abort(403, 'Invalid or expired stream link.');
        }

        $video = Video::findOrFail($id);
        $rawPath = $video->getRawOriginal('file_path');
        
        $path = $this->resolveVideoFilePath($rawPath);

        if (!$path || !file_exists($path)) {
            abort(404, 'Video file not found on server storage.');
        }

        return response()->file($path, [
            'Content-Type' => 'video/mp4',
            'Accept-Ranges' => 'bytes',
            'Cache-Control' => 'no-cache, no-store, must-revalidate',
        ]);
    }

    public function streamHls(Request $request, $id)
    {
        if (!$request->hasValidSignature()) {
            abort(403, 'Invalid or expired stream link.');
        }

        $video = Video::findOrFail($id);
        $rawHlsPath = $video->getRawOriginal('hls_path');
        
        $path = $this->resolveHlsPath($rawHlsPath);
        if (!$path || !file_exists($path)) {
            abort(404, 'Stream not found.');
        }

        return response()->file($path, [
            'Content-Type' => 'application/vnd.apple.mpegurl',
            'Cache-Control' => 'no-cache, no-store, must-revalidate',
            'Pragma' => 'no-cache',
            'Expires' => '0',
        ]);
    }

    public function streamSegment(Request $request, $id, $segment)
    {
        $video = Video::findOrFail($id);
        $rawHlsPath = $video->getRawOriginal('hls_path');
        $resolvedHls = $this->resolveHlsPath($rawHlsPath);

        $directory = $resolvedHls ? dirname($resolvedHls) : dirname(Storage::disk('private')->path($rawHlsPath));
        $segmentPath = $directory . '/' . $segment;

        if (!file_exists($segmentPath)) {
            abort(404, 'Segment not found.');
        }

        return response()->file($segmentPath, [
            'Content-Type' => 'video/MP2T',
            'Cache-Control' => 'public, max-age=3600',
        ]);
    }

    private function resolveVideoFilePath(?string $rawPath): ?string
    {
        if (empty($rawPath)) return null;

        $candidateLocations = [
            Storage::disk('private')->path($rawPath),
            Storage::disk('public')->path($rawPath),
            Storage::disk('local')->path($rawPath),
            Storage::disk('local')->path('private/' . $rawPath),
            storage_path('app/private/' . $rawPath),
            storage_path('app/' . $rawPath),
            storage_path('app/public/' . $rawPath),
            '/var/www/edustream/storage/app/private/' . $rawPath,
            '/var/www/edustream/storage/app/' . $rawPath,
            '/var/www/edustream/storage/app/public/' . $rawPath,
            base_path('../storage/app/private/' . $rawPath),
            base_path('../storage/app/' . $rawPath),
            base_path('../storage/app/public/' . $rawPath),
            public_path($rawPath),
            public_path('storage/' . $rawPath),
        ];

        foreach ($candidateLocations as $loc) {
            if (file_exists($loc) && is_file($loc)) {
                return $loc;
            }
        }

        return null;
    }

    private function resolveHlsPath(?string $rawHlsPath): ?string
    {
        if (empty($rawHlsPath)) return null;

        $candidateLocations = [
            Storage::disk('private')->path($rawHlsPath),
            Storage::disk('public')->path($rawHlsPath),
            Storage::disk('local')->path($rawHlsPath),
            Storage::disk('local')->path('private/' . $rawHlsPath),
            storage_path('app/private/' . $rawHlsPath),
            storage_path('app/' . $rawHlsPath),
            storage_path('app/public/' . $rawHlsPath),
            '/var/www/edustream/storage/app/private/' . $rawHlsPath,
            '/var/www/edustream/storage/app/' . $rawHlsPath,
            base_path('../storage/app/private/' . $rawHlsPath),
            base_path('../storage/app/' . $rawHlsPath),
        ];

        foreach ($candidateLocations as $loc) {
            if (file_exists($loc) && is_file($loc)) {
                return $loc;
            }
        }

        return null;
    }
}
