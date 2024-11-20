CREATE MIGRATION m15pz2zrsdgaqxxc77p3pvpsd7mdfwuxblihgyt73xvafsb2bfbojq
    ONTO m1n5sxnl7rljadhpit6qkwcg7mg53zhe3lxemgausgdpka4opw22fa
{
  ALTER TYPE activity::ParentChange {
      CREATE LINK action: default::Action {
          ON TARGET DELETE ALLOW;
          SET readonly := true;
      };
  };
  ALTER TYPE default::Primitive {
      DROP PROPERTY objectId;
  };
  ALTER TYPE default::TestStepRun {
      ALTER PROPERTY measurement {
          RENAME TO strValue;
      };
  };
};
