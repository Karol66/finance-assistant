import 'package:flutter/material.dart';
import 'package:frontend/common/color_extansion.dart';

class DashboardRow extends StatelessWidget {
  final Map sObj;
  final VoidCallback onPressed;

  const DashboardRow({super.key, required this.sObj, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {},
        child: Container(
            height: 64,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                border: Border.all(color: TColor.border.withOpacity(0.15)),
                borderRadius: BorderRadius.circular(10)),
            alignment: Alignment.center,
            child: Row(
              children: [
                const SizedBox(
                  width: 8,
                ),
                Image.asset(
                  sObj["icon"],
                  width: 40,
                  height: 40,
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Text(
                    sObj["name"],
                    style: TextStyle(
                      color: TColor.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Text(
                  "\$${sObj["price"]}",
                  style: TextStyle(
                    color: TColor.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
