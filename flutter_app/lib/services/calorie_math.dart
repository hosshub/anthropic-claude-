/// v1.3.0 — حساب ميزانية السعرات مع مقاصّة السعرات المحروقة من Apple Health.
/// السعرات المحروقة تُضاف إلى الهدف قبل طرح المستهلَك.
int adjustedGoal({required int goal, int burned = 0}) => goal + burned;

int calorieRemaining({
  required int goal,
  required int consumed,
  int burned = 0,
}) =>
    adjustedGoal(goal: goal, burned: burned) - consumed;
