import 'package:flutter/material.dart';
import 'package:salesforce/config.dart';
import 'package:salesforce/styles/colors.dart';

class ItemCounterWidget extends StatefulWidget {
  final Function? onAmountChanged;
  final double qty;

  const ItemCounterWidget({Key? key, this.onAmountChanged, required double this.qty}) : super(key: key);

  @override
  _ItemCounterWidgetState createState() => _ItemCounterWidgetState();
}

class _ItemCounterWidgetState extends State<ItemCounterWidget> {
  late double amount;

  @override
  void initState() {
    super.initState();
    amount = widget.qty; // Initialize amount with widget.qty
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        iconWidget(Icons.remove,
            iconColor: AppColors.darkGrey, onPressed: decrementAmount),
        
        Container(
            width: AppConfig.appSize(context, .04),
            child: Center(
                child: getText(
                    text: amount.toString(), fontSize: AppConfig.appSize(context, .014), isBold: true))),
        
        iconWidget(Icons.add,
            iconColor: AppColors.primaryColor, onPressed: incrementAmount)
      ],
    );
  }

  void incrementAmount() {
    setState(() {
      amount = amount + 1;
      updateParent();
    });
  }

  void decrementAmount() {
    if (amount <= 1) return;
    setState(() {
      amount = amount - 1;
      updateParent();
    });
  }

  void updateParent() {
    if (widget.onAmountChanged != null) {
      widget.onAmountChanged!(amount);
    }
  }

  Widget iconWidget(IconData iconData, {Color? iconColor, onPressed}) {
    return GestureDetector(
      onTap: () {
        if (onPressed != null) {
          onPressed();
        }
      },
      child: Container(
        height: AppConfig.appSize(context, .028),
        width: AppConfig.appSize(context, .028),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConfig.appSize(context, .012)),
          border: Border.all(
            color: Color(0xffE2E2E2),
          ),
        ),
        child: Center(
          child: Icon(
            iconData,
            color: iconColor ?? Colors.black,
            size: AppConfig.appSize(context, .016),
          ),
        ),
      ),
    );
  }

  Widget getText({
    required String text,
    required double fontSize,
    bool isBold = false,
    color = Colors.black,
  }) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        color: color,
      ),
    );
  }
}
