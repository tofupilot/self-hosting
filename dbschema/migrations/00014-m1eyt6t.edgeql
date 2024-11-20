CREATE MIGRATION m1eyt6tven4p47l5qxq6kf4cqrceioofrdq2362ndjsgc7v65s7wca
    ONTO m1t7z7ykumkqgyysclmfznlwb646x2rnzv6ekcdubzidgh6zcgmo6a
{
  ALTER TYPE default::Primitive {
      ALTER LINK createdBy {
          RESET readonly;
      };
  };
};
