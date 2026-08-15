<?php

namespace App\Http\Controllers;

use App\Models\Banner;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class BannerWebController extends Controller
{
    public function index()
    {
        $banners = Banner::orderBy('sort_order')->orderBy('created_at', 'desc')->get();
        return view('banners.index', compact('banners'));
    }

    public function store(Request $request)
    {
        $request->validate([
            'title'        => 'required|string|max:255',
            'subtitle'     => 'nullable|string|max:255',
            'icon'         => 'nullable|string|max:100',
            'color_start'  => 'nullable|string|max:20',
            'color_end'    => 'nullable|string|max:20',
            'image'        => 'nullable|image|mimes:jpeg,png,jpg,webp,svg|max:4096',
            'redirect_url' => 'nullable|string|max:500',
            'sort_order'   => 'nullable|integer|min:0',
            'status'       => 'nullable|in:active,inactive',
        ]);

        $imagePath = null;
        if ($request->hasFile('image')) {
            $path = $request->file('image')->store('banners', 'public');
            $imagePath = 'storage/' . $path;
        }

        Banner::create([
            'title'        => $request->title,
            'subtitle'     => $request->subtitle,
            'icon'         => $request->icon ?? 'fa-graduation-cap',
            'color_start'  => $request->color_start ?? '#1565C0',
            'color_end'    => $request->color_end ?? '#7B1FA2',
            'image_path'   => $imagePath,
            'redirect_url' => $request->redirect_url,
            'sort_order'   => $request->sort_order ?? 0,
            'status'       => $request->status ?? 'active',
        ]);

        return redirect('/banners')->with('success', 'Banner created successfully!');
    }

    public function edit(Banner $banner)
    {
        if (request()->wantsJson() || request()->ajax()) {
            return response()->json([
                'success' => true,
                'banner'  => $banner,
            ]);
        }
        return view('banners.edit', compact('banner'));
    }

    public function update(Request $request, Banner $banner)
    {
        $request->validate([
            'title'        => 'required|string|max:255',
            'subtitle'     => 'nullable|string|max:255',
            'icon'         => 'nullable|string|max:100',
            'color_start'  => 'nullable|string|max:20',
            'color_end'    => 'nullable|string|max:20',
            'image'        => 'nullable|image|mimes:jpeg,png,jpg,webp,svg|max:4096',
            'redirect_url' => 'nullable|string|max:500',
            'sort_order'   => 'nullable|integer|min:0',
            'status'       => 'nullable|in:active,inactive',
        ]);

        $data = [
            'title'        => $request->title,
            'subtitle'     => $request->subtitle,
            'icon'         => $request->icon ?? ($banner->icon ?? 'fa-graduation-cap'),
            'color_start'  => $request->color_start ?? ($banner->color_start ?? '#1565C0'),
            'color_end'    => $request->color_end ?? ($banner->color_end ?? '#7B1FA2'),
            'redirect_url' => $request->redirect_url,
            'sort_order'   => $request->sort_order ?? $banner->sort_order,
            'status'       => $request->status ?? $banner->status,
        ];

        if ($request->hasFile('image')) {
            // Delete old image if exists
            if ($banner->image_path && Storage::disk('public')->exists(str_replace('storage/', '', $banner->image_path))) {
                Storage::disk('public')->delete(str_replace('storage/', '', $banner->image_path));
            }
            $path = $request->file('image')->store('banners', 'public');
            $data['image_path'] = 'storage/' . $path;
        }

        $banner->update($data);

        if ($request->wantsJson() || $request->ajax()) {
            return response()->json([
                'success' => true,
                'message' => 'Banner updated successfully!',
                'banner'  => $banner,
            ]);
        }

        return redirect('/banners')->with('success', 'Banner updated successfully!');
    }

    public function toggleStatus(Banner $banner)
    {
        $banner->status = $banner->status === 'active' ? 'inactive' : 'active';
        $banner->save();

        if (request()->wantsJson() || request()->ajax()) {
            return response()->json([
                'success' => true,
                'status'  => $banner->status,
                'message' => 'Banner status set to ' . ucfirst($banner->status),
            ]);
        }

        return back()->with('success', 'Banner status updated to ' . ucfirst($banner->status) . '!');
    }

    public function destroy(Banner $banner)
    {
        if ($banner->image_path && Storage::disk('public')->exists(str_replace('storage/', '', $banner->image_path))) {
            Storage::disk('public')->delete(str_replace('storage/', '', $banner->image_path));
        }

        $banner->delete();

        if (request()->wantsJson() || request()->ajax()) {
            return response()->json([
                'success' => true,
                'message' => 'Banner deleted successfully!',
            ]);
        }

        return redirect('/banners')->with('success', 'Banner deleted successfully!');
    }
}
