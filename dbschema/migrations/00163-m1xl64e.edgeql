CREATE MIGRATION m1xl64etvqjit5nfbmweepkxpaml47zh23f4kko5gpjw6ixu6hbina
    ONTO m1bybuhmgnrtmjiugkm6c6hgj4taimnb2qpp2sq2xbr4rxbba6p6ea
{
  ALTER TYPE default::TestStepRun {
      CREATE REQUIRED LINK status: default::Status {
          ON TARGET DELETE ALLOW;
          SET REQUIRED USING (<default::Status>{});
      };
  };
  ALTER TYPE default::TestStepRun {
      DROP PROPERTY passed;
  };
};
