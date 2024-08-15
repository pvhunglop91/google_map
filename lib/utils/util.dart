import 'dart:math' as math;

class Util {
  Util._();

  static String getID() {
    String st = 'abcdefghijklmnopqrstuvwxyz';
    st = '${st}0123456789';
    String st2 = '';
    for (int i = 0; i <= 6; i++) {
      st2 = '$st2${st[math.Random().nextInt(st.length)]}';
    }
    return st2;
  }
}
