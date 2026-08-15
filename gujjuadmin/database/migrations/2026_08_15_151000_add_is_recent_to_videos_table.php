<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        if (!Schema::hasColumn('videos', 'is_recent')) {
            Schema::table('videos', function (Blueprint $table) {
                $table->boolean('is_recent')->default(false)->after('is_free');
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        if (Schema::hasColumn('videos', 'is_recent')) {
            Schema::table('videos', function (Blueprint $table) {
                $table->dropColumn('is_recent');
            });
        }
    }
};
