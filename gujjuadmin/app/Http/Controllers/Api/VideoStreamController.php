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

        // 1. If HLS processing completed and files exist, serve signed HLS
        if ($video->processing_status === 'completed' && $rawHlsPath && Storage::disk('private')->exists($rawHlsPath)) {
            $streamUrl = URL::temporarySignedRoute(
                'video.stream.hls',
                now()->addHours(4),
                ['id' => $video->id]
            );
        }
        // 2. Otherwise fallback to direct local MP4 file streaming
        elseif ($rawFilePath && (Storage::disk('private')->exists($rawFilePath) || Storage::disk('public')->exists($rawFilePath))) {
            $streamUrl = URL::temporarySignedRoute(
                'video.stream.direct',
                now()->addHours(4),
                ['id' => $video->id]
            );
        }
        // 3. Fallback to external/direct video URL
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
        
        $path = null;
        if ($rawPath && Storage::disk('private')->exists($rawPath)) {
            $path = Storage::disk('private')->path($rawPath);
        } elseif ($rawPath && Storage::disk('public')->exists($rawPath)) {
            $path = Storage::disk('public')->path($rawPath);
        }

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
        // This route should have 'signed' middleware
        if (!$request->hasValidSignature()) {
            abort(403, 'Invalid or expired stream link.');
        }

        $video = Video::findOrFail($id);
        $rawHlsPath = $video->getRawOriginal('hls_path');
        
        if (!$rawHlsPath || !Storage::disk('private')->exists($rawHlsPath)) {
            abort(404, 'Stream not found.');
        }

        // For large M3U8/TS files, typically you'd stream them or use a dedicated video server.
        // For standard local Laravel storage, we can return the M3U8 contents.
        // NOTE: A robust production setup should ideally serve HLS playlists and segments 
        // via a CDN or a separate media server route that handles .ts segments as well.
        // For this implementation, we will serve the M3U8 directly if requested.
        
        // ... existing comments ...
        $path = Storage::disk('private')->path($rawHlsPath);
        return response()->file($path, [
            'Content-Type' => 'application/vnd.apple.mpegurl',
            // Disable caching to prevent storing signed content
            'Cache-Control' => 'no-cache, no-store, must-revalidate',
            'Pragma' => 'no-cache',
            'Expires' => '0',
        ]);
    }

    public function streamSegment(Request $request, $id, $segment)
    {
        // For segments, we check if the video exists and the segment is in its HLS directory
        $video = Video::findOrFail($id);
        
        // Construct the path to the segment
        $rawHlsPath = $video->getRawOriginal('hls_path');
        $directory = dirname($rawHlsPath);
        $segmentPath = $directory . '/' . $segment;

        if (!Storage::disk('private')->exists($segmentPath)) {
            abort(404, 'Segment not found.');
        }

        $path = Storage::disk('private')->path($segmentPath);
        
        return response()->file($path, [
            'Content-Type' => 'video/MP2T',
            'Cache-Control' => 'public, max-age=3600', // Segments can be cached as they are static parts
        ]);
    }
}
