/// Helper functions for tracking system
class TrackingHelper {
  /// Check if order has tracking enabled
  static bool hasTracking(Map<String, dynamic> order) {
    final trackingId = order['trackingId'];
    return trackingId != null && trackingId.toString().isNotEmpty;
  }

  /// Get tracking ID from order
  static String? getTrackingId(Map<String, dynamic> order) {
    return order['trackingId']?.toString();
  }

  /// Get order ID
  static String? getOrderId(Map<String, dynamic> order) {
    return order['_id']?.toString();
  }

  /// Format tracking status for display
  static String formatStatus(String status) {
    switch (status) {
      case 'pending':
        return 'Chờ xử lý';
      case 'processing':
        return 'Đang xử lý';
      case 'shipped':
        return 'Đang giao';
      case 'delivered':
        return 'Đã giao';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  /// Get status color
  static String getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return '#FF9800';
      case 'processing':
        return '#2196F3';
      case 'shipped':
        return '#9C27B0';
      case 'delivered':
        return '#4CAF50';
      case 'cancelled':
        return '#F44336';
      default:
        return '#9E9E9E';
    }
  }

  /// Generate tracking URL for sharing
  static String generateTrackingUrl(String trackingId, {String baseUrl = 'https://yourapp.com'}) {
    return '$baseUrl/track/$trackingId';
  }

  /// Validate tracking ID format
  static bool isValidTrackingId(String? trackingId) {
    if (trackingId == null || trackingId.isEmpty) return false;
    // TRK + 13 digits + 6 uppercase letters
    final pattern = RegExp(r'^TRK\d{13}[A-Z]{6}$');
    return pattern.hasMatch(trackingId);
  }

  /// Extract order number from tracking ID
  static String getShortOrderNumber(String? trackingId) {
    if (trackingId == null || trackingId.isEmpty) return 'N/A';
    // Return last 8 characters
    return trackingId.length > 8 
        ? trackingId.substring(trackingId.length - 8) 
        : trackingId;
  }
}
