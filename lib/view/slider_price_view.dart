import 'package:enamduatekno/app_theme.dart';
import 'package:flutter/material.dart';


class SliderPriceView extends StatefulWidget {
  const SliderPriceView({Key? key, this.onChangepriceValue, this.priceValue})
      : super(key: key);

  final Function(double)? onChangepriceValue;
  final double? priceValue;

  @override
  _SliderViewState createState() => _SliderViewState();
}

class _SliderViewState extends State<SliderPriceView> {
  double priceValue = 50;

  @override
  void initState() {
    priceValue = widget.priceValue!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                flex: priceValue.round(),
                child: const SizedBox(),
              ),
              Container(
                width: 170,
                child: Text(
                  '\$${(priceValue).toStringAsFixed(0)}',
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 100 - priceValue.round(),
                child: const SizedBox(),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(),
            child: Slider(
              onChanged: (double value) {
                setState(() {
                  priceValue = value;
                });
                try {
                  widget.onChangepriceValue!(priceValue);
                } catch (_) {}
              },
              min: 1,
              max: 4,
              activeColor: AppTheme.mainColor,
              inactiveColor: Colors.grey.withOpacity(0.4),
              divisions: 4,
              value: priceValue,
            ),
          ),
        ],
      ),
    );
  }
}

