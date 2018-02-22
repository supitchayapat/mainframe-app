import 'package:flutter/material.dart';

/*
  [EventsListTile] extends class [ListTile]
  The class is tailored for the Application's Events menu
 */
class EventsListTile extends ListTile {
  Color leadingColor;
  EventsListTile({this.leadingColor, Widget leading, Widget trailing, Widget title, Widget subtitle, GestureTapCallback onTap})
      : super(leading: leading, trailing: trailing, title: title, subtitle: subtitle, onTap: onTap);

  bool _denseLayout(ListTileTheme tileTheme) {
    return dense != null ? dense : (tileTheme?.dense ?? false);
  }

  Color _iconColor(ThemeData theme, ListTileTheme tileTheme) {
    if (!enabled)
      return theme.disabledColor;

    if (selected && tileTheme?.selectedColor != null)
      return tileTheme.selectedColor;

    if (!selected && tileTheme?.iconColor != null)
      return tileTheme.iconColor;

    switch (theme.brightness) {
      case Brightness.light:
        return selected ? theme.primaryColor : Colors.black45;
      case Brightness.dark:
        return selected ? theme.accentColor : null; // null - use current icon theme color
    }
    assert(theme.brightness != null);
    return null;
  }

  Color _textColor(ThemeData theme, ListTileTheme tileTheme, Color defaultColor) {
    if (!enabled)
      return theme.disabledColor;

    if (selected && tileTheme?.selectedColor != null)
      return tileTheme.selectedColor;

    if (!selected && tileTheme?.textColor != null)
      return tileTheme.textColor;

    if (selected) {
      switch (theme.brightness) {
        case Brightness.light:
          return theme.primaryColor;
        case Brightness.dark:
          return theme.accentColor;
      }
    }
    return defaultColor;
  }

  TextStyle _subtitleTextStyle(ThemeData theme, ListTileTheme tileTheme) {
    final TextStyle style = theme.textTheme.body1;
    final Color color = _textColor(theme, tileTheme, theme.textTheme.caption.color);
    return _denseLayout(tileTheme)
        ? style.copyWith(color: color, fontSize: 12.0)
        : style.copyWith(color: color);
  }

  TextStyle _titleTextStyle(ThemeData theme, ListTileTheme tileTheme) {
    final TextStyle style = tileTheme?.style == ListTileStyle.drawer
        ? theme.textTheme.body2
        : theme.textTheme.subhead;
    final Color color = _textColor(theme, tileTheme, style.color);
    return _denseLayout(tileTheme)
        ? style.copyWith(fontSize: 13.0, color: color)
        : style.copyWith(color: color);
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    final ThemeData theme = Theme.of(context);
    final ListTileTheme tileTheme = ListTileTheme.of(context);

    final bool isTwoLine = !isThreeLine && subtitle != null;
    final bool isOneLine = !isThreeLine && !isTwoLine;
    double tileHeight;
    if (isOneLine)
      tileHeight = _denseLayout(tileTheme) ? 48.0 : 56.0;
    else if (isTwoLine)
      tileHeight = _denseLayout(tileTheme) ? 60.0 : 72.0;
    else
      tileHeight = _denseLayout(tileTheme) ? 76.0 : 88.0;
    // Overall, the list tile is a Row() with these children.
    final List<Widget> children = <Widget>[];

    IconThemeData iconThemeData;
    if (leading != null || trailing != null)
      iconThemeData = new IconThemeData(color: _iconColor(theme, tileTheme));

    if (leading != null) {
      children.add(IconTheme.merge(
        data: iconThemeData,
        child: new Container(
          margin: const EdgeInsetsDirectional.only(end: 10.0),
          //padding: const EdgeInsets.all(5.0),
          width: 140.0,
          color: leadingColor != null ? leadingColor : new Color(0xffffffff),
          alignment: AlignmentDirectional.centerStart,
          child: leading,
        ),
      ));
    }

    final Widget primaryLine = new AnimatedDefaultTextStyle(
        style: _titleTextStyle(theme, tileTheme),
        duration: kThemeChangeDuration,
        child: title ?? new Container()
    );
    Widget center = primaryLine;
    if (subtitle != null && (isTwoLine || isThreeLine)) {
      center = new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          primaryLine,
          new AnimatedDefaultTextStyle(
            style: _subtitleTextStyle(theme, tileTheme),
            duration: kThemeChangeDuration,
            child: subtitle,
          ),
        ],
      );
    }
    children.add(new Expanded(
      child: center,
    ));

    if (trailing != null) {
      children.add(IconTheme.merge(
        data: iconThemeData,
        child: new Container(
          //color: Colors.amber,
          margin: const EdgeInsetsDirectional.only(start: 3.0, end: 5.0),
          alignment: AlignmentDirectional.centerEnd,
          child: trailing,
        ),
      ));
    }

    return new InkWell(
        onTap: enabled ? onTap : null,
        onLongPress: enabled ? onLongPress : null,
        child: new Container(
          decoration: new BoxDecoration(
            border: new Border(
              bottom: new BorderSide(
                  color: Colors.black
              ),
            ),
          ),
          height: 80.0,
          //padding: const EdgeInsets.only(top: 1.5, bottom: 1.5),
          child: new Row(children: children),
        )
    );
  }
}

class ListTileText extends StatelessWidget {
  Key key;
  TextAlign textAlign;
  TextDirection textDirection;
  bool softWrap;
  TextOverflow overflow;
  double textScaleFactor;
  int maxLines;
  String data;
  ListTileText(this.data, {this.key, this.textAlign, this.textDirection,
    this.softWrap, this.overflow, this.textScaleFactor, this.maxLines});

  @override
  Widget build(BuildContext context) {
    TextStyle style = new TextStyle(
        color: Colors.white
    );
    if(data.length > 28) {
      style = new TextStyle(
          color: Colors.white,
          fontSize: 14.0
      );
    }
    if(data.length >= 68) {
      data = "${data.substring(0, 65)}...";
    }
    return new Text(data,
        style: style,
        overflow: overflow,
        textDirection: textDirection,
        key: key,
        maxLines: maxLines,
        softWrap: softWrap,
        textAlign: textAlign,
        textScaleFactor: textScaleFactor);
  }
}