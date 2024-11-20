CREATE MIGRATION m147bj23xegdszbuybllz7xwdbp7pumdr2auvmagf7y4n2khhrbvma
    ONTO m17v2xungu5uvmlruuvltygz54q7kpnmqvxn4kqfao43ygbw3pcnia
{
  ALTER TYPE default::Primitive {
      ALTER LINK attachments {
          ON TARGET DELETE ALLOW;
      };
  };
};
