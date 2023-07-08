import 'package:pdf/widgets.dart';

class CustomText extends StatelessWidget {
  CustomText(
    this.text, {
    this.style,
    this.textAlign,
    this.textDirection,
    this.softWrap,
    this.tightBounds = false,
    this.textScaleFactor = 1.0,
    this.maxLines,
    this.overflow = TextOverflow.visible,
  });

  bool _isRtlChar(String char) {
    assert(char.length == 1);
    final code = char.codeUnitAt(0);
    return code >= 0x0600 && code <= 0x06ff;
  }

  bool _isNumericChar(String char) {
    assert(char.length == 1);
    final code = char.codeUnitAt(0);
    return code >= '0'.codeUnitAt(0) && code <= '9'.codeUnitAt(0);
  }

  bool _isNeutralChar(String char) {
    assert(char.length == 1);
    return '!@#\$%^&*()_++\'\\":/.>,<:،…؛×÷`ّ~ '.contains(char);
  }

  List<String> _getTextList() {
    final textList = [''];

    var isLastCharRtl = false;
    for (int index = 0; index < text.length; index++) {
      if (_isRtlChar(text[index]) ||
          ((_isNumericChar(text[index]) || _isNeutralChar(text[index])) &&
              isLastCharRtl)) {
        isLastCharRtl
            ? textList.last += text[index]
            : textList.add(text[index]);

        isLastCharRtl = true;
      } else {
        isLastCharRtl
            ? textList.add(text[index])
            : textList.last += text[index];

        isLastCharRtl = false;
      }
    }

    if (textList[0].isEmpty) textList.removeAt(0);

    return textList;
  }

  List<Widget> _getTextRow(Context context) {
    final textAlign = _getTextAlign(context);
    final textRow = <Text>[];

    for (final text in _getTextList()) {
      var textDirection = this.textDirection;
      if (_isRtlChar(text[0])) textDirection = TextDirection.rtl;

      textRow.add(
        Text(
          text,
          textAlign: textAlign,
          textDirection: textDirection,
          softWrap: softWrap,
          tightBounds: tightBounds,
          textScaleFactor: textScaleFactor,
          maxLines: maxLines,
          overflow: overflow,
        ),
      );
    }

    return textRow;
  }

  @override
  Widget build(Context context) {
    return Wrap(
      alignment: _getWrapAlignment(context),
      children: _getTextRow(context),
    );
  }

  TextAlign? _getTextAlign(Context context) {
    if (Directionality.of(context) == TextDirection.rtl) {
      if (textAlign != null) {
        if (textAlign == TextAlign.right) return TextAlign.left;
        if (textAlign == TextAlign.left) return TextAlign.right;
      }
      return TextAlign.right;
    }
    return textAlign;
  }

  WrapAlignment _getWrapAlignment(Context context) {
    if (Directionality.of(context) == TextDirection.rtl) {
      if (textAlign != null) {
        if (textAlign == TextAlign.right) return WrapAlignment.start;
        if (textAlign == TextAlign.left) return WrapAlignment.end;
      }
      return WrapAlignment.end;
    }
    return WrapAlignment.start;
  }

  final String text;

  final TextStyle? style;

  final TextAlign? textAlign;

  final TextDirection? textDirection;

  final double textScaleFactor;

  final bool? softWrap;

  final bool tightBounds;

  final int? maxLines;

  final TextOverflow? overflow;
}

class CustomColumn extends StatelessWidget {
  CustomColumn({
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.verticalDirection = VerticalDirection.down,
    this.textDirection,
    this.children = const <Widget>[],
  });

  final MainAxisAlignment mainAxisAlignment;

  final MainAxisSize mainAxisSize;

  final CrossAxisAlignment crossAxisAlignment;

  final VerticalDirection verticalDirection;

  final TextDirection? textDirection;

  final List<Widget> children;

  @override
  Widget build(Context context) {
    return Column(
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: _getCrossAxisAlignment(context),
      verticalDirection: verticalDirection,
      children: children,
    );
  }

  CrossAxisAlignment _getCrossAxisAlignment(Context context) {
    if (Directionality.of(context) == TextDirection.rtl) {
      if (crossAxisAlignment == CrossAxisAlignment.start) {
        return CrossAxisAlignment.end;
      }
      if (crossAxisAlignment == CrossAxisAlignment.end) {
        return CrossAxisAlignment.start;
      }
    }
    return crossAxisAlignment;
  }
}

class CustomRow extends StatelessWidget {
  CustomRow({
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.verticalDirection = VerticalDirection.down,
    this.textDirection,
    this.children = const <Widget>[],
  });

  final MainAxisAlignment mainAxisAlignment;

  final MainAxisSize mainAxisSize;

  final CrossAxisAlignment crossAxisAlignment;

  final VerticalDirection verticalDirection;

  final TextDirection? textDirection;

  final List<Widget> children;

  @override
  Widget build(Context context) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      verticalDirection: verticalDirection,
      children: _getChildren(context),
    );
  }

  List<Widget> _getChildren(Context context) {
    final textDirection = this.textDirection ?? Directionality.of(context);
    return textDirection == TextDirection.ltr
        ? children
        : children.reversed.toList();
  }
}
