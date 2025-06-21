import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/enums/dummy_order_status.dart';
import '../../../../core/providers/order_provider.dart';
import 'order_status_row.dart';

class OrderStatusColumn extends StatelessWidget {
  const OrderStatusColumn({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        final order = orderProvider.currentOrder;
        if (order == null) {
          return const Text('No order data available');
        }

        String formatDateTime(DateTime? dateTime) {
          if (dateTime == null) return '--';
          return '${dateTime.day}.${dateTime.month}.${dateTime.year}';
        }

        String formatTime(DateTime? dateTime) {
          if (dateTime == null) return '--';
          return '${dateTime.hour.toString().padLeft(2, '0')}.${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.hour >= 12 ? 'PM' : 'AM'}';
        }

        // Determine which steps are active based on order status
        bool isConfirmedActive = order.confirmedAt != null;
        bool isProcessingActive = order.processingAt != null;
        bool isShippedActive = order.shippedAt != null;
        bool isDeliveredActive = order.deliveredAt != null;

        return Column(
          children: [
            OrderStatusRow(
              status: OrderStatus.confirmed,
              date: formatDateTime(order.confirmedAt),
              time: formatTime(order.confirmedAt),
              isStart: true,
              isActive: isConfirmedActive,
            ),
            OrderStatusRow(
              status: OrderStatus.processing,
              date: formatDateTime(order.processingAt),
              time: formatTime(order.processingAt),
              isActive: isProcessingActive,
            ),
            OrderStatusRow(
              status: OrderStatus.shipped,
              date: formatDateTime(order.shippedAt),
              time: formatTime(order.shippedAt),
              isActive: isShippedActive,
            ),
            OrderStatusRow(
              status: OrderStatus.delivery,
              date: formatDateTime(order.deliveredAt),
              time: formatTime(order.deliveredAt),
              isEnd: true,
              isActive: isDeliveredActive,
            ),
          ],
        );
      },
    );
  }
}
