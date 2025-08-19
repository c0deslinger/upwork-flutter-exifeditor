import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'exif_preview_page.dart';

class ExifLibrarySelectorPage extends StatelessWidget {
  static const routeName = "/exifLibrarySelector";
  final String imagePath;

  const ExifLibrarySelectorPage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select EXIF Library',
          style: GoogleFonts.mPlusRounded1c(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose EXIF Library',
                style: GoogleFonts.mPlusRounded1c(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.purple.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select which library to use for reading EXIF data',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 32),

              // Library Options
              Expanded(
                child: ListView(
                  children: [
                    _buildLibraryOption(
                      title: 'Native EXIF',
                      subtitle: 'Fast native implementation',
                      icon: Icons.speed,
                      color: Colors.blue,
                      onTap: () => _navigateToExifEditor('native_exif'),
                    ),
                    const SizedBox(height: 16),
                    _buildLibraryOption(
                      title: 'EXIF Reader',
                      subtitle: 'Comprehensive EXIF reader',
                      icon: Icons.book,
                      color: Colors.green,
                      onTap: () => _navigateToExifEditor('exif_reader'),
                    ),
                    const SizedBox(height: 16),
                    _buildLibraryOption(
                      title: 'Metadata',
                      subtitle: 'Metadata EXIF reader',
                      icon: Icons.data_array,
                      color: const Color.fromARGB(255, 111, 157, 112),
                      onTap: () => _navigateToExifEditor('metadata'),
                    ),
                    const SizedBox(height: 16),
                    _buildLibraryOption(
                      title: 'EXIF Package',
                      subtitle: 'Traditional EXIF package',
                      icon: Icons.library_books,
                      color: Colors.orange,
                      onTap: () => _navigateToExifEditor('exif'),
                    ),
                    const SizedBox(height: 16),
                    _buildLibraryOption(
                      title: 'Simple Exif',
                      subtitle: 'Simple Exif reader',
                      icon: Icons.lightbulb,
                      color: Colors.teal,
                      onTap: () => _navigateToExifEditor('simple_exif'),
                    ),
                    const SizedBox(height: 16),
                    _buildLibraryOption(
                      title: 'Image Library',
                      subtitle: 'Image library EXIF reader',
                      icon: Icons.image,
                      color: Colors.purple,
                      onTap: () => _navigateToExifEditor('image_library'),
                    ),
                    const SizedBox(height: 16),
                    _buildLibraryOption(
                      title: 'Combined Approach',
                      subtitle: 'Try all libraries for best results',
                      icon: Icons.merge_type,
                      color: Colors.red,
                      onTap: () => _navigateToExifEditor('combined'),
                    ),
                    const SizedBox(height: 16),
                    _buildLibraryOption(
                      title: 'Native Platform',
                      subtitle: 'Use platform-specific EXIF reading',
                      icon: Icons.phone_android,
                      color: Colors.indigo,
                      onTap: () => _navigateToExifEditor('native_platform'),
                    ),
                    const SizedBox(height: 16),
                    _buildLibraryOption(
                      title: 'Native Platform Advanced',
                      subtitle: 'Advanced Android ExifInterface features',
                      icon: Icons.engineering,
                      color: Colors.amber,
                      onTap: () =>
                          _navigateToExifEditor('native_platform_advanced'),
                    ),
                    const SizedBox(height: 16),
                    _buildLibraryOption(
                      title: 'Universal Approach',
                      subtitle: 'Best method for current platform',
                      icon: Icons.devices,
                      color: Colors.deepPurple,
                      onTap: () => _navigateToExifEditor('universal'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLibraryOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.mPlusRounded1c(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToExifEditor(String libraryType) {
    Get.toNamed(
      ExifPreviewPage.routeName,
      arguments: {
        'imagePath': imagePath,
        'libraryType': libraryType,
      },
    );
  }
}
