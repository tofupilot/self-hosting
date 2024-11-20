CREATE MIGRATION m1frhgkftaz6ozrvotbvtzep5loxxknb2vx7aofyhdo5nkdzvp2iwq
    ONTO m1ebqo4k5yx43h3j5xkcohfrtyyhkqx2rfxcrw6kxn66xxtuy4nepa
{
  ALTER TYPE default::Session {
      ALTER LINK user {
          ON TARGET DELETE ALLOW;
      };
  };
};
