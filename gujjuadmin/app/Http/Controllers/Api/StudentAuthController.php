<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\AuthService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;

class StudentAuthController extends Controller
{
    protected $emailService;

    public function __construct(AuthService $authService, \App\Services\EmailService $emailService)
    {
        $this->authService = $authService;
        $this->emailService = $emailService;
    }

    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|unique:students,email,NULL,id,deleted_at,NULL',
            'course_id' => 'required|exists:courses,id',
            'mobile' => 'nullable|string|digits:10|unique:students,mobile,NULL,id,deleted_at,NULL',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        // Finalize student account
        $password = \Illuminate\Support\Str::random(10);

        $student = \App\Models\Student::create([
            'name' => $request->name,
            'email' => $request->email,
            'mobile' => $request->mobile ?? null,
            'course_id' => $request->course_id,
            'password' => \Illuminate\Support\Facades\Hash::make($password),
            'status' => 'active',
            'email_verified_at' => now(),
        ]);

        $token = auth()->guard('api-student')->login($student);

        return response()->json([
            'message' => 'Student registered successfully',
            'student' => $student,
            'token' => $token,
        ], 201);
    }

    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|string|email',
            'password' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $result = $this->authService->loginStudent($request->email, $request->password);

        if (!$result) {
            return response()->json(['error' => 'Invalid credentials'], 401);
        }

        try {
            \Illuminate\Support\Facades\Mail::to($result['student']->email)->queue(new \App\Mail\LoginDetectedMail($result['student']));
        } catch (\Exception $e) {
            \Illuminate\Support\Facades\Log::error('Failed to send LoginDetectedMail: ' . $e->getMessage());
        }

        return response()->json([
            'student' => $result['student'],
            'token' => $result['token'],
        ]);
    }

    public function sendOtp(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'email' => 'required|string|email',
                'purpose' => 'required|in:login,signup,reset,switch_mode',
            ]);

            if ($validator->fails()) {
                return response()->json(['errors' => $validator->errors()], 422);
            }

            $email = strtolower(trim($request->email));
            $purpose = trim($request->purpose);

            // Check user existence based on purpose
            $studentExists = \App\Models\Student::where('email', $email)->exists();

            if ($purpose === 'signup' && $studentExists) {
                return response()->json(['error' => 'This email is already registered. Please login.'], 400);
            }

            if ($purpose === 'login' && !$studentExists) {
                return response()->json(['error' => 'Account not found. Please signup first.'], 400);
            }

            // Always generate a brand new 6-digit OTP
            $otp = (string) rand(100000, 999999);
            
            // Delete all previous OTP records for this email to avoid stale/duplicate row issues
            \Illuminate\Support\Facades\DB::table('otp_verifications')
                ->where('email', $email)
                ->delete();

            // Insert fresh OTP with 15 minutes validity
            \Illuminate\Support\Facades\DB::table('otp_verifications')->insert([
                'email' => $email,
                'otp' => $otp,
                'purpose' => $purpose,
                'attempts' => 0,
                'expires_at' => now()->addMinutes(15),
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            \Illuminate\Support\Facades\Log::info("OTP generated for {$email} ({$purpose}): {$otp}");

            // Send OTP via Email
            $sent = $this->emailService->sendOtpEmail($email, $otp, $purpose);

            if (!$sent) {
                return response()->json(['error' => 'Failed to send OTP email. Please ensure your email is correct and try again.'], 500);
            }

            return response()->json([
                'message' => 'OTP sent successfully to your email',
                'email' => $email,
            ]);
        } catch (\Exception $e) {
            \Illuminate\Support\Facades\Log::error('sendOtp error: ' . $e->getMessage());
            return response()->json(['error' => 'Server Error: ' . $e->getMessage()], 500);
        }
    }

    public function verifyOtp(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|string|email',
            'otp' => 'required|string',
            'purpose' => 'required|in:login,signup,reset,switch_mode',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $email = strtolower(trim($request->email));
        $otp = trim((string) $request->otp);
        $purpose = trim($request->purpose);

        $otpRecord = \Illuminate\Support\Facades\DB::table('otp_verifications')
            ->where('email', $email)
            ->orderBy('id', 'desc')
            ->first();

        if (!$otpRecord) {
            return response()->json(['error' => 'No OTP found for this email. Please request a new OTP.'], 400);
        }

        /** @var object $otpRecord */
        if (now()->greaterThan($otpRecord->expires_at)) {
            \Illuminate\Support\Facades\DB::table('otp_verifications')->where('id', $otpRecord->id)->delete();
            return response()->json(['error' => 'OTP expired. Please request a new OTP.'], 400);
        }

        if ($otpRecord->attempts >= 5) {
            \Illuminate\Support\Facades\DB::table('otp_verifications')->where('id', $otpRecord->id)->delete();
            return response()->json(['error' => 'Max OTP attempts reached. Please request a new OTP.'], 400);
        }

        if (trim((string) $otpRecord->otp) !== $otp) {
            \Illuminate\Support\Facades\DB::table('otp_verifications')
                ->where('id', $otpRecord->id)
                ->increment('attempts');
            return response()->json(['error' => 'Invalid OTP. Please check the code sent to your email.'], 400);
        }

        // Success - Clear OTP for this email
        \Illuminate\Support\Facades\DB::table('otp_verifications')->where('email', $email)->delete();

        if ($purpose === 'signup' || $otpRecord->purpose === 'signup') {
            return response()->json([
                'status' => 'needs_signup',
                'email' => $email
            ]);
        }

        // Login flow
        $student = \App\Models\Student::where('email', $email)->first();
        
        if (!$student) {
            return response()->json(['error' => 'Student not found.'], 404);
        }

        $token = auth()->guard('api-student')->login($student);

        try {
            \Illuminate\Support\Facades\Mail::to($student->email)->queue(new \App\Mail\LoginDetectedMail($student));
        } catch (\Exception $e) {
            \Illuminate\Support\Facades\Log::error('Failed to send LoginDetectedMail: ' . $e->getMessage());
        }

        return response()->json([
            'status' => 'login',
            'message' => 'Login successful',
            'student' => $student,
            'token' => $token
        ]);
    }

    public function me()
    {
        return response()->json(auth()->guard('api-student')->user());
    }

    public function logout()
    {
        $this->authService->logoutStudent();
        return response()->json(['message' => 'Successfully logged out']);
    }

    public function refresh()
    {
        $token = $this->authService->refreshToken();
        return response()->json(['token' => $token]);
    }

    public function updateProfile(Request $request)
    {
        $student = auth()->guard('api-student')->user();
        
        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|string|max:255',
            'mobile' => 'sometimes|string|digits:10|unique:students,mobile,' . $student->id . ',id,deleted_at,NULL',
            'bio' => 'nullable|string',
            'password' => 'sometimes|string|min:6|confirmed',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        // Strictly ignore email changes to maintain data consistency
        $data = $request->only(['name', 'mobile', 'bio']);
        if ($request->has('password')) {
            $data['password'] = bcrypt($request->password);
        }

        $student->update($data);

        return response()->json([
            'message' => 'Profile updated successfully',
            'student' => $student
        ]);
    }

    public function checkUser(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|string|email',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $student = \App\Models\Student::where('email', $request->email)->first();

        if (!$student) {
            return response()->json(['exists' => false]);
        }

        return response()->json([
            'exists' => true,
            'auth_mode' => $student->auth_mode,
        ]);
    }

    public function resetPassword(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'email' => 'required|string|email',
                'otp' => 'required|string',
                'password' => 'required|string|min:6|confirmed',
            ]);

            if ($validator->fails()) {
                return response()->json(['errors' => $validator->errors()], 422);
            }

            $email = strtolower(trim($request->email));
            $otp = trim((string) $request->otp);

            $otpRecord = \Illuminate\Support\Facades\DB::table('otp_verifications')
                ->where('email', $email)
                ->orderBy('id', 'desc')
                ->first();

            if (!$otpRecord || trim((string)$otpRecord->otp) !== $otp || now()->greaterThan($otpRecord->expires_at)) {
                return response()->json(['error' => 'Invalid or expired OTP.'], 400);
            }

            $student = \App\Models\Student::where('email', $email)->first();
            if (!$student) {
                return response()->json(['error' => 'Student not found.'], 404);
            }

            $student->update([
                'password' => \Illuminate\Support\Facades\Hash::make($request->password)
            ]);

            \Illuminate\Support\Facades\DB::table('otp_verifications')->where('email', $email)->delete();

            return response()->json(['message' => 'Password reset successfully']);
        } catch (\Exception $e) {
            \Illuminate\Support\Facades\Log::error('resetPassword error: ' . $e->getMessage());
            return response()->json(['error' => 'Server Error: ' . $e->getMessage()], 500);
        }
    }

    public function switchMode(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'otp' => 'required|string',
                'auth_mode' => 'required|in:otp,password',
                'password' => 'required_if:auth_mode,password|string|min:6|confirmed',
            ]);

            if ($validator->fails()) {
                return response()->json(['errors' => $validator->errors()], 422);
            }

            $student = auth()->guard('api-student')->user();

            if (!$student) {
                return response()->json(['error' => 'Unauthorized or User not found.'], 401);
            }

            $otpRecord = \Illuminate\Support\Facades\DB::table('otp_verifications')
                ->where('email', $student->email)
                ->where('purpose', 'switch_mode')
                ->first();

            if (!$otpRecord || $otpRecord->otp !== $request->otp || now()->greaterThan($otpRecord->expires_at)) {
                return response()->json(['error' => 'Invalid or expired OTP.'], 400);
            }

            $updateData = ['auth_mode' => $request->auth_mode];
            if ($request->auth_mode === 'password') {
                $updateData['password'] = \Illuminate\Support\Facades\Hash::make($request->password);
            }

            $student->update($updateData);

            \Illuminate\Support\Facades\DB::table('otp_verifications')->where('id', $otpRecord->id)->delete();

            return response()->json(['message' => 'Authentication mode switched successfully', 'student' => $student]);
        } catch (\Exception $e) {
            \Illuminate\Support\Facades\Log::error('switchMode error: ' . $e->getMessage());
            return response()->json(['error' => 'Server Error: ' . $e->getMessage()], 500);
        }
    }
}
