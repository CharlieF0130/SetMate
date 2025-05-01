extension DateTimeLeap on DateTime {
  bool get isLeapYear {
    final year = this.year;
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }
}
