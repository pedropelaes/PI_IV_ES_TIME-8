extension StringExtension on String {
      String capitalize() {
        if (isEmpty) return ''; // Lida com strings vazias
        return '${this[0].toUpperCase()}${substring(1)}';
      }
    }