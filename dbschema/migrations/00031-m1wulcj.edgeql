CREATE MIGRATION m1wulcjecmmqeo722zn6z2awt5ixvmm6yk6nfglwlbwe7vajodm63q
    ONTO m1frhgkftaz6ozrvotbvtzep5loxxknb2vx7aofyhdo5nkdzvp2iwq
{
  ALTER TYPE default::Session {
      ALTER LINK user {
          ON TARGET DELETE DELETE SOURCE;
      };
  };
  ALTER TYPE default::User {
      ALTER LINK imageUploaded {
          ON TARGET DELETE ALLOW;
      };
  };
};
