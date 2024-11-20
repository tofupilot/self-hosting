CREATE MIGRATION m1u2ciqcqnnnfpjgrqhquamu5dpcimmkb7zeqlzlszwpovmqjljava
    ONTO m1isyjzovap7tq3sn6eh4b6bd5feybv7lv5oiqzezxy6cf6ai5iyua
{
  ALTER TYPE default::Primitive {
      DROP LINK estimatedTimeChanges;
      DROP LINK targetDateChanges;
      DROP PROPERTY targetDate;
  };
  DROP TYPE activity::EstimatedTimeChange;
  DROP TYPE activity::TargetDateChange;
};