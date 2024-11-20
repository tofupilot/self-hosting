CREATE MIGRATION m1cnfvozg5odkw4dfta5tcdyegc3ogw7cqknbjodzxffv7fon7sdgq
    ONTO m1eyt6tven4p47l5qxq6kf4cqrceioofrdq2362ndjsgc7v65s7wca
{
  ALTER TYPE default::Primitive {
      ALTER LINK createdBy {
          SET readonly := true;
      };
  };
  ALTER TYPE default::Primitive {
      ALTER LINK links {
          ON TARGET DELETE ALLOW;
      };
  };
};
