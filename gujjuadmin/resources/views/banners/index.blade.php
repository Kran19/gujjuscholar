@extends('layouts.app', ['title' => 'Explore Tab Banners'])

@section('subtitle', 'Manage banners shown on the student app — carousel, custom promotional images, gradients, and redirect links')

@section('styles')
<style>
/* Banner Page Styles */
.banner-context-bar {
    background: linear-gradient(135deg, #1565C0, #7B1FA2);
    border-radius: var(--r-lg);
    padding: 16px 24px;
    margin-bottom: 28px;
    display: flex;
    align-items: center;
    gap: 16px;
    color: white;
}
.banner-context-icon { font-size: 28px; opacity: 0.9; }
.banner-context-title { font-size: 15px; font-weight: 700; margin-bottom: 2px; }
.banner-context-desc { font-size: 12px; opacity: 0.85; line-height: 1.5; }

/* Banner Grid */
.banner-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 22px; margin-bottom: 32px; }
.banner-card { background: var(--surface); border: 1px solid var(--border); border-radius: var(--r-lg); overflow: hidden; transition: all var(--tr); display: flex; flex-direction: column; }
.banner-card:hover { box-shadow: var(--shadow-lg); transform: translateY(-3px); }

/* Banner Preview Box */
.banner-preview {
    height: 160px;
    display: flex;
    align-items: center;
    justify-content: center;
    position: relative;
    overflow: hidden;
    background-size: cover;
    background-position: center;
}
.banner-preview-overlay {
    position: absolute;
    inset: 0;
    background: linear-gradient(to top, rgba(0,0,0,0.7) 0%, rgba(0,0,0,0.2) 60%, transparent 100%);
    z-index: 1;
}
.banner-preview-icon {
    font-size: 48px;
    color: rgba(255,255,255,0.92);
    z-index: 2;
    filter: drop-shadow(0 4px 10px rgba(0,0,0,0.3));
}
.banner-preview-content {
    position: absolute;
    bottom: 12px;
    left: 16px;
    right: 16px;
    z-index: 2;
    color: white;
}
.banner-preview-title {
    font-size: 15px;
    font-weight: 700;
    text-shadow: 0 2px 4px rgba(0,0,0,0.4);
    line-height: 1.2;
}
.banner-preview-subtitle {
    font-size: 12px;
    opacity: 0.9;
    font-weight: 400;
    display: block;
    margin-top: 3px;
    text-shadow: 0 1px 3px rgba(0,0,0,0.4);
}
.banner-type-badge {
    position: absolute;
    top: 12px;
    right: 12px;
    background: rgba(0,0,0,0.55);
    backdrop-filter: blur(4px);
    color: white;
    font-size: 10px;
    font-weight: 700;
    padding: 3px 8px;
    border-radius: 6px;
    z-index: 2;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

/* Card Body & Footer */
.banner-card-body {
    padding: 14px 16px;
    flex: 1;
    display: flex;
    flex-direction: column;
    gap: 8px;
}
.banner-meta-row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    font-size: 12px;
    color: var(--text-muted);
}
.banner-redirect-link {
    font-size: 11px;
    color: var(--primary);
    text-decoration: none;
    display: flex;
    align-items: center;
    gap: 5px;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    max-width: 100%;
}
.banner-redirect-link:hover { text-decoration: underline; }

.banner-card-footer {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 12px 16px;
    border-top: 1px solid var(--border);
    background: var(--surface-2);
}
.status-badge { font-size: 11px; font-weight: 700; padding: 4px 10px; border-radius: 30px; display: inline-flex; align-items: center; gap: 5px; }
.status-active { background: #E8F5E9; color: #2E7D32; border: 1px solid #A5D6A7; }
.status-inactive { background: #FFEBEE; color: #C62828; border: 1px solid #FFCDD2; }

.action-btn-group { display: flex; gap: 6px; align-items: center; }
.btn-icon {
    width: 34px;
    height: 34px;
    border-radius: 8px;
    border: none;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all var(--tr);
    font-size: 13px;
    text-decoration: none;
}
.btn-toggle-active { background: #E8F5E9; color: #2E7D32; }
.btn-toggle-active:hover { background: #2E7D32; color: white; }
.btn-toggle-inactive { background: #FFF3E0; color: #E65100; }
.btn-toggle-inactive:hover { background: #E65100; color: white; }
.btn-edit { background: #E3F2FD; color: #1565C0; }
.btn-edit:hover { background: #1565C0; color: white; }
.btn-delete { background: #FFEBEE; color: #C62828; }
.btn-delete:hover { background: #C62828; color: white; }

/* Add/Edit Form Card */
.form-card {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: var(--r-lg);
    padding: 28px;
    margin-bottom: 32px;
    box-shadow: var(--shadow-sm);
}
.form-section-title { font-size: 16px; font-weight: 700; margin-bottom: 20px; display: flex; align-items: center; gap: 10px; color: var(--text); }
.form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
.form-group { margin-bottom: 18px; }
.form-label { display: block; font-size: 12px; font-weight: 700; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.5px; color: var(--text-muted); }
.form-control {
    width: 100%;
    padding: 10px 14px;
    border: 1px solid var(--border);
    border-radius: var(--r-sm);
    background: var(--surface);
    color: var(--text);
    font-size: 14px;
    box-sizing: border-box;
    transition: all var(--tr);
}
.form-control:focus { outline: none; border-color: var(--primary); box-shadow: 0 0 0 3px rgba(21,101,192,0.1); }

/* Icon Picker */
.icon-picker { display: grid; grid-template-columns: repeat(8, 1fr); gap: 8px; margin-top: 8px; }
.icon-option {
    width: 100%;
    aspect-ratio: 1;
    display: flex;
    align-items: center;
    justify-content: center;
    border: 1.5px solid var(--border);
    border-radius: 10px;
    cursor: pointer;
    font-size: 17px;
    transition: all var(--tr);
    background: var(--surface-2);
    color: var(--text-muted);
}
.icon-option:hover { border-color: var(--primary); color: var(--primary); background: var(--surface); }
.icon-option.selected { border-color: var(--primary); background: #E3F2FD; color: var(--primary); }

/* Gradient Presets */
.gradient-presets { display: flex; gap: 10px; flex-wrap: wrap; margin-top: 8px; }
.gradient-preset { width: 36px; height: 36px; border-radius: 8px; cursor: pointer; border: 2.5px solid transparent; transition: all var(--tr); }
.gradient-preset:hover { transform: scale(1.1); }
.gradient-preset.selected { border-color: var(--text); box-shadow: 0 2px 6px rgba(0,0,0,0.2); }

/* Live Preview */
.live-preview {
    height: 140px;
    border-radius: 16px;
    display: flex;
    align-items: center;
    justify-content: center;
    position: relative;
    overflow: hidden;
    margin-top: 8px;
    transition: background 0.3s ease;
    background-size: cover;
    background-position: center;
}
.live-preview-overlay { position: absolute; inset: 0; background: linear-gradient(to top, rgba(0,0,0,0.7) 0%, transparent 80%); z-index: 1; }
.live-preview-icon { font-size: 44px; color: rgba(255,255,255,0.92); z-index: 2; }
.live-preview-content { position: absolute; bottom: 12px; left: 16px; right: 16px; color: white; z-index: 2; }
.live-preview-title { font-weight: 700; font-size: 14px; text-shadow: 0 1px 4px rgba(0,0,0,0.4); }
.live-preview-sub { font-size: 11px; opacity: 0.9; text-shadow: 0 1px 3px rgba(0,0,0,0.4); }

/* Color pickers row */
.color-row { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
.color-input-wrapper { display: flex; align-items: center; gap: 10px; border: 1px solid var(--border); border-radius: var(--r-sm); padding: 6px 12px; background: var(--surface); }
.color-input-wrapper input[type=color] { width: 28px; height: 28px; border: none; padding: 0; border-radius: 6px; cursor: pointer; background: transparent; }
.color-input-wrapper span { font-size: 13px; color: var(--text-muted); font-weight: 500; }

/* Modal */
.modal-backdrop {
    display: none;
    position: fixed;
    top: 0; left: 0; right: 0; bottom: 0;
    background: rgba(0,0,0,0.6);
    backdrop-filter: blur(4px);
    z-index: 1050;
    align-items: center;
    justify-content: center;
}
.modal-backdrop.show { display: flex; }
.modal {
    background: var(--surface);
    border-radius: var(--r-lg);
    width: 90%;
    max-width: 680px;
    max-height: 90vh;
    overflow-y: auto;
    box-shadow: 0 20px 40px rgba(0,0,0,0.25);
    animation: modalFadeIn 0.25s ease-out;
}
@keyframes modalFadeIn { from { opacity: 0; transform: translateY(-15px); } to { opacity: 1; transform: translateY(0); } }
.modal-header { padding: 18px 24px; border-bottom: 1px solid var(--border); display: flex; align-items: center; justify-content: space-between; }
.modal-header h3 { font-size: 17px; font-weight: 700; margin: 0; }
.modal-close { background: transparent; border: none; font-size: 24px; cursor: pointer; color: var(--text-muted); line-height: 1; }
.modal-close:hover { color: var(--text); }
.modal-body { padding: 24px; }
.modal-footer { padding: 16px 24px; border-top: 1px solid var(--border); display: flex; align-items: center; justify-content: flex-end; gap: 12px; background: var(--surface-2); }

/* Empty State */
.empty-box { text-align: center; padding: 60px 20px; background: var(--surface); border-radius: var(--r-lg); border: 1px dashed var(--border); margin-bottom: 32px; }
</style>
@endsection

@section('actions')
    <a href="#addBannerSection" class="quick-action-btn" style="text-decoration: none;">
        <i class="fa-solid fa-plus"></i> Add New Banner
    </a>
@endsection

@section('content')
<div class="animate-fade-up">

    @if(session('success'))
    <div style="background: #E8F5E9; color: #2E7D32; padding: 12px 20px; border-radius: var(--r); margin-bottom: 24px; display: flex; align-items: center; gap: 10px; border: 1px solid #A5D6A7;">
        <i class="fa-solid fa-circle-check"></i> {{ session('success') }}
    </div>
    @endif

    @if($errors->any())
    <div style="background: #FFEBEE; color: #C62828; padding: 12px 20px; border-radius: var(--r); margin-bottom: 24px; border: 1px solid #FFCDD2;">
        <ul style="margin: 0; padding-left: 20px;">
            @foreach($errors->all() as $error)
                <li>{{ $error }}</li>
            @endforeach
        </ul>
    </div>
    @endif

    {{-- Context Bar --}}
    <div class="banner-context-bar">
        <div class="banner-context-icon"><i class="fa-solid fa-mobile-screen"></i></div>
        <div>
            <div class="banner-context-title">Student App Banners (Home & Explore Carousel)</div>
            <div class="banner-context-desc">
                Manage promotional banners, announcements, and featured course sliders displayed at the top of the student app.
                Supports custom uploaded banner images, rich gradients, icons, redirect URLs, and instant 1-click ON/OFF toggle.
            </div>
        </div>
        <div style="margin-left: auto; font-size: 13px; opacity: 0.95; white-space: nowrap; font-weight: 700; background: rgba(255,255,255,0.2); padding: 6px 14px; border-radius: 20px;">
            <i class="fa-solid fa-toggle-on"></i> {{ $banners->where('status','active')->count() }} Active / {{ $banners->count() }} Total
        </div>
    </div>

    {{-- Existing Banners --}}
    @if($banners->isEmpty())
    <div class="empty-box">
        <i class="fa-solid fa-images" style="font-size: 48px; color: var(--text-muted); margin-bottom: 16px; display: block;"></i>
        <h3 style="margin-bottom: 8px;">No banners yet</h3>
        <p style="color: var(--text-muted); margin-bottom: 0;">Use the form below to create your first mobile app banner.</p>
    </div>
    @else
    <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 16px;">
        <h2 style="font-size: 16px; font-weight: 700;">{{ $banners->count() }} Banner{{ $banners->count() != 1 ? 's' : '' }} Available</h2>
        <span style="font-size: 12px; color: var(--text-muted);"><i class="fa-solid fa-arrow-down-short-wide"></i> Ordered by sort priority</span>
    </div>

    <div class="banner-grid">
        @foreach($banners as $banner)
        @php
            $cs = $banner->color_start ?? '#1565C0';
            $ce = $banner->color_end ?? '#7B1FA2';
            $icon = $banner->icon ?? 'fa-graduation-cap';
            $hasImage = !empty($banner->image_path);
            $bgStyle = $hasImage 
                ? "background-image: url('" . asset($banner->image_path) . "');" 
                : "background: linear-gradient(135deg, $cs, $ce);";
        @endphp
        <div class="banner-card">
            {{-- Visual Preview --}}
            <div class="banner-preview" style="{{ $bgStyle }}">
                <div class="banner-preview-overlay"></div>
                @if($hasImage)
                    <span class="banner-type-badge"><i class="fa-solid fa-image"></i> Image Banner</span>
                @else
                    <span class="banner-type-badge"><i class="fa-solid fa-palette"></i> Gradient Banner</span>
                    <i class="fa-solid {{ $icon }} banner-preview-icon"></i>
                @endif
                <div class="banner-preview-content">
                    <div class="banner-preview-title">{{ $banner->title }}</div>
                    @if($banner->subtitle)
                        <span class="banner-preview-subtitle">{{ $banner->subtitle }}</span>
                    @endif
                </div>
            </div>

            {{-- Card Body --}}
            <div class="banner-card-body">
                <div class="banner-meta-row">
                    <span><i class="fa-solid fa-sort"></i> Sort Order: <strong>{{ $banner->sort_order }}</strong></span>
                    <span>
                        @if($banner->status === 'active')
                            <span class="status-badge status-active"><i class="fa-solid fa-circle" style="font-size: 7px;"></i> Active</span>
                        @else
                            <span class="status-badge status-inactive"><i class="fa-solid fa-circle" style="font-size: 7px;"></i> Inactive</span>
                        @endif
                    </span>
                </div>
                @if($banner->redirect_url)
                <div class="banner-redirect-link" title="{{ $banner->redirect_url }}">
                    <i class="fa-solid fa-link"></i> {{ Str::limit($banner->redirect_url, 38) }}
                </div>
                @else
                <div style="font-size: 11px; color: var(--text-muted);"><i class="fa-solid fa-link-slash"></i> No redirect link</div>
                @endif
            </div>

            {{-- Card Footer & Actions --}}
            <div class="banner-card-footer">
                {{-- Status Toggle Form (ON / OFF) --}}
                <form action="{{ url('banners/' . $banner->id . '/toggle') }}" method="POST" style="margin: 0;">
                    @csrf @method('PATCH')
                    @if($banner->status === 'active')
                        <button type="submit" class="btn-icon btn-toggle-active" title="Banner is ON. Click to turn OFF">
                            <i class="fa-solid fa-toggle-on" style="font-size: 18px;"></i>
                        </button>
                    @else
                        <button type="submit" class="btn-icon btn-toggle-inactive" title="Banner is OFF. Click to turn ON">
                            <i class="fa-solid fa-toggle-off" style="font-size: 18px;"></i>
                        </button>
                    @endif
                </form>

                <div class="action-btn-group">
                    {{-- Edit Button (Opens Modal) --}}
                    <button type="button" class="btn-icon btn-edit" title="Edit Banner" onclick="openEditModal({{ json_encode($banner) }})">
                        <i class="fa-solid fa-pen-to-square"></i>
                    </button>

                    {{-- Delete Form --}}
                    <form action="{{ url('banners/' . $banner->id) }}" method="POST" style="margin: 0;" onsubmit="return confirm('Are you sure you want to delete banner: \'{{ $banner->title }}\'?')">
                        @csrf @method('DELETE')
                        <button type="submit" class="btn-icon btn-delete" title="Delete Banner">
                            <i class="fa-solid fa-trash-can"></i>
                        </button>
                    </form>
                </div>
            </div>
        </div>
        @endforeach
    </div>
    @endif

    {{-- Add Banner Form --}}
    <div class="form-card" id="addBannerSection">
        <div class="form-section-title">
            <i class="fa-solid fa-plus-circle" style="color: var(--primary);"></i>
            Create New Banner
        </div>
        <form action="{{ url('banners') }}" method="POST" enctype="multipart/form-data">
            @csrf
            <div class="form-row">
                <div>
                    <div class="form-group">
                        <label class="form-label">Banner Title *</label>
                        <input type="text" name="title" id="addTitleInput" class="form-control" placeholder="e.g., Standard 10 Board Special Batch!" required oninput="updateAddLivePreview()">
                    </div>

                    <div class="form-group">
                        <label class="form-label">Banner Subtitle / Tagline</label>
                        <input type="text" name="subtitle" id="addSubInput" class="form-control" placeholder="e.g., Complete chapter-wise videos & practice tests" oninput="updateAddLivePreview()">
                    </div>

                    <div class="form-group">
                        <label class="form-label">Redirect Link / Target Action (Optional)</label>
                        <input type="text" name="redirect_url" class="form-control" placeholder="e.g., /course/1 or https://gujjuscholar.in/special-offer">
                    </div>

                    <div class="form-row" style="margin-bottom: 0;">
                        <div class="form-group">
                            <label class="form-label">Sort Priority</label>
                            <input type="number" name="sort_order" class="form-control" value="0" min="0">
                        </div>
                        <div class="form-group">
                            <label class="form-label">Status (ON / OFF)</label>
                            <select name="status" class="form-control">
                                <option value="active">Active (ON)</option>
                                <option value="inactive">Inactive (OFF)</option>
                            </select>
                        </div>
                    </div>
                </div>

                <div>
                    {{-- Optional Image Upload --}}
                    <div class="form-group">
                        <label class="form-label">Custom Image Upload (Optional)</label>
                        <input type="file" name="image" id="addImageInput" class="form-control" accept="image/*" onchange="previewAddImage(this)">
                        <small style="color: var(--text-muted); font-size: 11px;">Recommended size: 1200x600px. If uploaded, the image replaces the icon gradient.</small>
                    </div>

                    {{-- Gradient Colors --}}
                    <div class="form-group">
                        <label class="form-label">Gradient Colors (Fallback / Background)</label>
                        <div class="color-row">
                            <div class="color-input-wrapper">
                                <input type="color" id="addColorStart" name="color_start" value="#1565C0" oninput="updateAddLivePreview()">
                                <span>Start Color</span>
                            </div>
                            <div class="color-input-wrapper">
                                <input type="color" id="addColorEnd" name="color_end" value="#7B1FA2" oninput="updateAddLivePreview()">
                                <span>End Color</span>
                            </div>
                        </div>
                        <div class="gradient-presets">
                            <div class="gradient-preset selected" style="background: linear-gradient(135deg, #1565C0, #7B1FA2);" onclick="applyAddPreset('#1565C0', '#7B1FA2', this)"></div>
                            <div class="gradient-preset" style="background: linear-gradient(135deg, #E65100, #F57C00);" onclick="applyAddPreset('#E65100', '#F57C00', this)"></div>
                            <div class="gradient-preset" style="background: linear-gradient(135deg, #1B5E20, #388E3C);" onclick="applyAddPreset('#1B5E20', '#388E3C', this)"></div>
                            <div class="gradient-preset" style="background: linear-gradient(135deg, #880E4F, #AD1457);" onclick="applyAddPreset('#880E4F', '#AD1457', this)"></div>
                            <div class="gradient-preset" style="background: linear-gradient(135deg, #006064, #00838F);" onclick="applyAddPreset('#006064', '#00838F', this)"></div>
                            <div class="gradient-preset" style="background: linear-gradient(135deg, #263238, #455A64);" onclick="applyAddPreset('#263238', '#455A64', this)"></div>
                        </div>
                    </div>

                    {{-- Icon Picker --}}
                    <div class="form-group">
                        <label class="form-label">Icon</label>
                        <input type="hidden" name="icon" id="addSelectedIcon" value="fa-graduation-cap">
                        <div class="icon-picker" id="addIconPicker">
                            <div class="icon-option selected" data-icon="fa-graduation-cap" onclick="selectAddIcon('fa-graduation-cap', this)"><i class="fa-solid fa-graduation-cap"></i></div>
                            <div class="icon-option" data-icon="fa-book-open" onclick="selectAddIcon('fa-book-open', this)"><i class="fa-solid fa-book-open"></i></div>
                            <div class="icon-option" data-icon="fa-star" onclick="selectAddIcon('fa-star', this)"><i class="fa-solid fa-star"></i></div>
                            <div class="icon-option" data-icon="fa-trophy" onclick="selectAddIcon('fa-trophy', this)"><i class="fa-solid fa-trophy"></i></div>
                            <div class="icon-option" data-icon="fa-fire" onclick="selectAddIcon('fa-fire', this)"><i class="fa-solid fa-fire"></i></div>
                            <div class="icon-option" data-icon="fa-bolt" onclick="selectAddIcon('fa-bolt', this)"><i class="fa-solid fa-bolt"></i></div>
                            <div class="icon-option" data-icon="fa-rocket" onclick="selectAddIcon('fa-rocket', this)"><i class="fa-solid fa-rocket"></i></div>
                            <div class="icon-option" data-icon="fa-gift" onclick="selectAddIcon('fa-gift', this)"><i class="fa-solid fa-gift"></i></div>
                        </div>
                    </div>

                    {{-- Live Preview --}}
                    <div>
                        <label class="form-label">Live App Banner Preview</label>
                        <div class="live-preview" id="addLivePreviewBox" style="background: linear-gradient(135deg, #1565C0, #7B1FA2);">
                            <div class="live-preview-overlay"></div>
                            <i class="fa-solid fa-graduation-cap live-preview-icon" id="addLiveIcon"></i>
                            <div class="live-preview-content">
                                <div class="live-preview-title" id="addLiveTitle">Banner Title Preview</div>
                                <div class="live-preview-sub" id="addLiveSub">Banner subtitle preview</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div style="display: flex; justify-content: flex-end; margin-top: 20px; padding-top: 20px; border-top: 1px solid var(--border);">
                <button type="submit" class="btn btn-primary" style="padding: 12px 28px; font-weight: 700; font-size: 14px;">
                    <i class="fa-solid fa-cloud-arrow-up"></i> Save & Publish Banner
                </button>
            </div>
        </form>
    </div>

</div>

{{-- EDIT BANNER MODAL --}}
<div class="modal-backdrop" id="editBannerModal" onclick="if(event.target===this) closeEditModal()">
    <div class="modal">
        <div class="modal-header">
            <h3><i class="fa-solid fa-pen-to-square" style="color: var(--primary); margin-right: 8px;"></i> Edit Banner</h3>
            <button class="modal-close" onclick="closeEditModal()">&times;</button>
        </div>
        <form id="editBannerForm" action="" method="POST" enctype="multipart/form-data">
            @csrf
            @method('PUT')
            <div class="modal-body">
                <div class="form-group">
                    <label class="form-label">Banner Title *</label>
                    <input type="text" name="title" id="editTitleInput" class="form-control" required oninput="updateEditLivePreview()">
                </div>

                <div class="form-group">
                    <label class="form-label">Banner Subtitle / Tagline</label>
                    <input type="text" name="subtitle" id="editSubInput" class="form-control" oninput="updateEditLivePreview()">
                </div>

                <div class="form-group">
                    <label class="form-label">Redirect Link / Action</label>
                    <input type="text" name="redirect_url" id="editRedirectInput" class="form-control" placeholder="e.g., /course/10 or https://gujjuscholar.in">
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Sort Priority</label>
                        <input type="number" name="sort_order" id="editSortInput" class="form-control" min="0">
                    </div>
                    <div class="form-group">
                        <label class="form-label">Status (ON / OFF)</label>
                        <select name="status" id="editStatusSelect" class="form-control">
                            <option value="active">Active (ON)</option>
                            <option value="inactive">Inactive (OFF)</option>
                        </select>
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label">Replace Custom Image (Optional)</label>
                    <input type="file" name="image" id="editImageInput" class="form-control" accept="image/*" onchange="previewEditImage(this)">
                </div>

                <div class="form-group">
                    <label class="form-label">Gradient Colors</label>
                    <div class="color-row">
                        <div class="color-input-wrapper">
                            <input type="color" id="editColorStart" name="color_start" oninput="updateEditLivePreview()">
                            <span>Start Color</span>
                        </div>
                        <div class="color-input-wrapper">
                            <input type="color" id="editColorEnd" name="color_end" oninput="updateEditLivePreview()">
                            <span>End Color</span>
                        </div>
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label">Icon</label>
                    <input type="hidden" name="icon" id="editSelectedIcon">
                    <div class="icon-picker" id="editIconPicker">
                        <div class="icon-option" data-icon="fa-graduation-cap" onclick="selectEditIcon('fa-graduation-cap', this)"><i class="fa-solid fa-graduation-cap"></i></div>
                        <div class="icon-option" data-icon="fa-book-open" onclick="selectEditIcon('fa-book-open', this)"><i class="fa-solid fa-book-open"></i></div>
                        <div class="icon-option" data-icon="fa-star" onclick="selectEditIcon('fa-star', this)"><i class="fa-solid fa-star"></i></div>
                        <div class="icon-option" data-icon="fa-trophy" onclick="selectEditIcon('fa-trophy', this)"><i class="fa-solid fa-trophy"></i></div>
                        <div class="icon-option" data-icon="fa-fire" onclick="selectEditIcon('fa-fire', this)"><i class="fa-solid fa-fire"></i></div>
                        <div class="icon-option" data-icon="fa-bolt" onclick="selectEditIcon('fa-bolt', this)"><i class="fa-solid fa-bolt"></i></div>
                        <div class="icon-option" data-icon="fa-rocket" onclick="selectEditIcon('fa-rocket', this)"><i class="fa-solid fa-rocket"></i></div>
                        <div class="icon-option" data-icon="fa-gift" onclick="selectEditIcon('fa-gift', this)"><i class="fa-solid fa-gift"></i></div>
                    </div>
                </div>

                <div>
                    <label class="form-label">Live Preview</label>
                    <div class="live-preview" id="editLivePreviewBox">
                        <div class="live-preview-overlay"></div>
                        <i class="fa-solid fa-graduation-cap live-preview-icon" id="editLiveIcon"></i>
                        <div class="live-preview-content">
                            <div class="live-preview-title" id="editLiveTitle">Title</div>
                            <div class="live-preview-sub" id="editLiveSub">Subtitle</div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" onclick="closeEditModal()">Cancel</button>
                <button type="submit" class="btn btn-primary"><i class="fa-solid fa-save"></i> Save Changes</button>
            </div>
        </form>
    </div>
</div>

<script>
// --- ADD FORM HELPERS ---
let addCustomImageSrc = null;

function updateAddLivePreview() {
    const cs = document.getElementById('addColorStart').value;
    const ce = document.getElementById('addColorEnd').value;
    const title = document.getElementById('addTitleInput').value.trim() || 'Banner Title Preview';
    const sub = document.getElementById('addSubInput').value.trim() || 'Banner subtitle preview';
    const icon = document.getElementById('addSelectedIcon').value;
    const box = document.getElementById('addLivePreviewBox');
    const iconEl = document.getElementById('addLiveIcon');

    if (addCustomImageSrc) {
        box.style.background = `url('${addCustomImageSrc}') center/cover no-repeat`;
        iconEl.style.display = 'none';
    } else {
        box.style.background = `linear-gradient(135deg, ${cs}, ${ce})`;
        iconEl.style.display = 'block';
        iconEl.className = `fa-solid ${icon} live-preview-icon`;
    }

    document.getElementById('addLiveTitle').innerText = title;
    document.getElementById('addLiveSub').innerText = sub;
}

function selectAddIcon(iconClass, el) {
    document.getElementById('addSelectedIcon').value = iconClass;
    document.querySelectorAll('#addIconPicker .icon-option').forEach(i => i.classList.remove('selected'));
    el.classList.add('selected');
    updateAddLivePreview();
}

function applyAddPreset(cs, ce, el) {
    document.getElementById('addColorStart').value = cs;
    document.getElementById('addColorEnd').value = ce;
    document.querySelectorAll('.gradient-presets .gradient-preset').forEach(p => p.classList.remove('selected'));
    el.classList.add('selected');
    updateAddLivePreview();
}

function previewAddImage(input) {
    if (input.files && input.files[0]) {
        const reader = new FileReader();
        reader.onload = function(e) {
            addCustomImageSrc = e.target.result;
            updateAddLivePreview();
        };
        reader.readAsDataURL(input.files[0]);
    } else {
        addCustomImageSrc = null;
        updateAddLivePreview();
    }
}

// --- EDIT MODAL HELPERS ---
let editCustomImageSrc = null;

function openEditModal(banner) {
    document.getElementById('editBannerForm').action = "{{ url('banners') }}/" + banner.id;
    document.getElementById('editTitleInput').value = banner.title || '';
    document.getElementById('editSubInput').value = banner.subtitle || '';
    document.getElementById('editRedirectInput').value = banner.redirect_url || '';
    document.getElementById('editSortInput').value = banner.sort_order ?? 0;
    document.getElementById('editStatusSelect').value = banner.status || 'active';
    document.getElementById('editColorStart').value = banner.color_start || '#1565C0';
    document.getElementById('editColorEnd').value = banner.color_end || '#7B1FA2';
    document.getElementById('editSelectedIcon').value = banner.icon || 'fa-graduation-cap';
    document.getElementById('editImageInput').value = '';

    // Highlight selected icon
    const iconClass = banner.icon || 'fa-graduation-cap';
    document.querySelectorAll('#editIconPicker .icon-option').forEach(i => {
        if (i.getAttribute('data-icon') === iconClass) {
            i.classList.add('selected');
        } else {
            i.classList.remove('selected');
        }
    });

    if (banner.image_path) {
        editCustomImageSrc = "{{ asset('') }}" + banner.image_path.replace(/^\//, '');
    } else {
        editCustomImageSrc = null;
    }

    updateEditLivePreview();
    document.getElementById('editBannerModal').classList.add('show');
}

function closeEditModal() {
    document.getElementById('editBannerModal').classList.remove('show');
}

function selectEditIcon(iconClass, el) {
    document.getElementById('editSelectedIcon').value = iconClass;
    document.querySelectorAll('#editIconPicker .icon-option').forEach(i => i.classList.remove('selected'));
    el.classList.add('selected');
    updateEditLivePreview();
}

function updateEditLivePreview() {
    const cs = document.getElementById('editColorStart').value;
    const ce = document.getElementById('editColorEnd').value;
    const title = document.getElementById('editTitleInput').value.trim() || 'Banner Title';
    const sub = document.getElementById('editSubInput').value.trim() || 'Banner subtitle';
    const icon = document.getElementById('editSelectedIcon').value;
    const box = document.getElementById('editLivePreviewBox');
    const iconEl = document.getElementById('editLiveIcon');

    if (editCustomImageSrc) {
        box.style.background = `url('${editCustomImageSrc}') center/cover no-repeat`;
        iconEl.style.display = 'none';
    } else {
        box.style.background = `linear-gradient(135deg, ${cs}, ${ce})`;
        iconEl.style.display = 'block';
        iconEl.className = `fa-solid ${icon} live-preview-icon`;
    }

    document.getElementById('editLiveTitle').innerText = title;
    document.getElementById('editLiveSub').innerText = sub;
}

function previewEditImage(input) {
    if (input.files && input.files[0]) {
        const reader = new FileReader();
        reader.onload = function(e) {
            editCustomImageSrc = e.target.result;
            updateEditLivePreview();
        };
        reader.readAsDataURL(input.files[0]);
    }
}
</script>
@endsection
