CREATE MIGRATION m1jzrrge3jemkinctlacnpobp3bm64toh2wwhi33zc4g4enwxwp7da
    ONTO m1cnfvozg5odkw4dfta5tcdyegc3ogw7cqknbjodzxffv7fon7sdgq
{
  ALTER TYPE default::Primitive {
      ALTER LINK assignee {
          ON TARGET DELETE ALLOW;
      };
  };
  ALTER TYPE default::Primitive {
      ALTER LINK labels {
          ON TARGET DELETE ALLOW;
      };
  };
  ALTER TYPE default::Primitive {
      ALTER LINK status {
          ON TARGET DELETE ALLOW;
      };
  };
};
