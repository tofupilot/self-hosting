CREATE MIGRATION m1ttmjfikgulue7kc3hhsena234ssx7wtlslh547jkjoedjj2cxn5q
    ONTO m1dobfp6744alahvnxfsuxn3mzoxtmjv6s2ehfb6xtnfnycrnwqg6q
{
  ALTER TYPE activity::StatusChange {
      ALTER LINK new {
          ON TARGET DELETE DELETE SOURCE;
      };
  };
  ALTER TYPE activity::StatusChange {
      ALTER LINK old {
          ON TARGET DELETE DELETE SOURCE;
      };
  };
};
