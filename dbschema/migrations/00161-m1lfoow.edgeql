CREATE MIGRATION m1lfoowgnku4hvsum73555yl2j3ujl5cygemuyvbhd4ytqnydqhffa
    ONTO m1rlytv6ojtl4jbltnhbuiauvb3krcec4subuuod33n5gdnebmcjlq
{
  ALTER TYPE default::Action {
      ALTER PROPERTY duration {
          RESET readonly;
          SET OWNED;
          RESET CARDINALITY;
          SET TYPE std::duration;
      };
      CREATE PROPERTY startedAt: std::datetime;
      CREATE PROPERTY endedAt := ((.startedAt + .duration));
  };
  ALTER TYPE default::Primitive {
      DROP PROPERTY duration;
  };
  ALTER TYPE default::TestStepRun {
      CREATE PROPERTY duration: std::duration;
      ALTER PROPERTY endedAt {
          USING ((.startedAt + .duration));
      };
  };
};
