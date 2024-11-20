CREATE MIGRATION m1bybuhmgnrtmjiugkm6c6hgj4taimnb2qpp2sq2xbr4rxbba6p6ea
    ONTO m1lfoowgnku4hvsum73555yl2j3ujl5cygemuyvbhd4ytqnydqhffa
{
  ALTER TYPE default::Action {
      DROP PROPERTY endedAt;
  };
  ALTER TYPE default::TestStep {
      ALTER PROPERTY highLimit {
          SET TYPE std::float64;
      };
      ALTER PROPERTY lowLimit {
          SET TYPE std::float64;
      };
      ALTER PROPERTY name {
          SET REQUIRED USING (<std::str>{});
      };
  };
  ALTER TYPE default::TestStepRun {
      ALTER PROPERTY duration {
          SET REQUIRED USING (<std::duration>{});
      };
      DROP PROPERTY endedAt;
      ALTER PROPERTY passed {
          SET REQUIRED USING (<std::bool>{});
      };
      ALTER PROPERTY startedAt {
          SET REQUIRED USING (<std::datetime>{});
      };
      ALTER PROPERTY value {
          SET TYPE std::float64;
      };
  };
};
