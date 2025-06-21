import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';
import '../../../core/constants/payment_constants.dart';
import '../../../core/components/network_image.dart';
import 'checkout_payment_card_tile.dart';
import 'checkout_payment_option_tile.dart';
import '../../profile/payment_method/components/default_card.dart';

class PaymentSystem extends StatefulWidget {
  final PaymentType selectedPaymentType;
  final Function(PaymentType) onPaymentTypeChanged;
  
  const PaymentSystem({
    super.key,
    required this.selectedPaymentType,
    required this.onPaymentTypeChanged,
  });

  @override
  State<PaymentSystem> createState() => _PaymentSystemState();
}

class _PaymentSystemState extends State<PaymentSystem> {

  Widget _buildPaymentDetails() {
    switch (widget.selectedPaymentType) {
      case PaymentType.masterCard:
        return Column(
          children: [
            // My Card section header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDefaults.padding,
                vertical: AppDefaults.padding / 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Card',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.add, color: Colors.white),
                      iconSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            // Credit Card Display
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppDefaults.padding),
              child: PaymentDefaultCard(),
            ),
          ],
        );

      case PaymentType.paypal:
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDefaults.padding,
            vertical: AppDefaults.padding / 2,
          ),
          child: Container(
            padding: const EdgeInsets.all(AppDefaults.padding),
            decoration: BoxDecoration(
              color: AppColors.coloredBackground,
              borderRadius: AppDefaults.borderRadius,
              border: Border.all(color: AppColors.primary),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: NetworkImageWithLoader(
                      'https://i.imgur.com/7pI5714.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Paypal',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'mypaypal@gmail.com',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
        );

      case PaymentType.cashOnDelivery:
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDefaults.padding,
            vertical: AppDefaults.padding / 2,
          ),
          child: Container(
            padding: const EdgeInsets.all(AppDefaults.padding),
            decoration: BoxDecoration(
              color: AppColors.coloredBackground,
              borderRadius: AppDefaults.borderRadius,
              border: Border.all(color: AppColors.primary),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.green[100],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: NetworkImageWithLoader(
                      'https://i.imgur.com/aRJj3iU.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Cash on Delivery',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pay in Cash when your order arrives',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
        );

      case PaymentType.applePay:
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDefaults.padding,
            vertical: AppDefaults.padding / 2,
          ),
          child: Container(
            padding: const EdgeInsets.all(AppDefaults.padding),
            decoration: BoxDecoration(
              color: AppColors.coloredBackground,
              borderRadius: AppDefaults.borderRadius,
              border: Border.all(color: AppColors.primary),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.black,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: NetworkImageWithLoader(
                      'https://i.imgur.com/lLUcMC1.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Apple Pay',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'applepay.com',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Payment selection buttons
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDefaults.padding,
            vertical: AppDefaults.padding / 2,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Select Payment System',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppDefaults.padding),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              PaymentCardTile(
                label: 'Master Card',
                icon: AppIcons.masterCard,
                onTap: () {
                  widget.onPaymentTypeChanged(PaymentType.masterCard);
                },
                isActive: widget.selectedPaymentType == PaymentType.masterCard,
              ),
                             PaymentCardTile(
                 label: 'Paypal',
                 icon: 'https://i.imgur.com/7pI5714.png',
                 onTap: () {
                   widget.onPaymentTypeChanged(PaymentType.paypal);
                 },
                 isActive: widget.selectedPaymentType == PaymentType.paypal,
               ),
               PaymentCardTile(
                 label: 'Cash On Delivery',
                 icon: 'https://i.imgur.com/aRJj3iU.png',
                 onTap: () {
                   widget.onPaymentTypeChanged(PaymentType.cashOnDelivery);
                 },
                 isActive: widget.selectedPaymentType == PaymentType.cashOnDelivery,
               ),
               PaymentCardTile(
                 label: 'Apple Pay',
                  icon: 'https://i.imgur.com/lLUcMC1.png',
                 onTap: () {
                   widget.onPaymentTypeChanged(PaymentType.applePay);
                 },
                 isActive: widget.selectedPaymentType == PaymentType.applePay,
               ),
            ],
          ),
        ),
        
        const SizedBox(height: AppDefaults.padding),
        
        // Dynamic payment details based on selection
        _buildPaymentDetails(),
      ],
    );
  }
}
