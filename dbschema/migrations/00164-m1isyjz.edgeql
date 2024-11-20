CREATE MIGRATION m1isyjzovap7tq3sn6eh4b6bd5feybv7lv5oiqzezxy6cf6ai5iyua
    ONTO m1xl64etvqjit5nfbmweepkxpaml47zh23f4kko5gpjw6ixu6hbina
{
  ALTER TYPE default::TestStep {
      DROP PROPERTY highLimit;
      DROP PROPERTY lowLimit;
      DROP PROPERTY measurement;
      DROP PROPERTY units;
  };
  ALTER TYPE default::TestStepRun {
      CREATE PROPERTY highLimit: std::float64;
      CREATE PROPERTY lowLimit: std::float64;
      CREATE PROPERTY measurement: std::str;
      CREATE PROPERTY units: std::str;
  };
};
