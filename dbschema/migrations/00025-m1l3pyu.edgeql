CREATE MIGRATION m1l3pyuqbhhsg3ngdx2rfda27ipemeqh65z3bwyimftqx2od7avdaa
    ONTO m1ocoj6avtydbu7r2lhoxvljexodewvj7cwk3xas6zqlfun37kkgvq
{
  ALTER TYPE default::Primitive {
      DROP LINK uploads;
  };
};
