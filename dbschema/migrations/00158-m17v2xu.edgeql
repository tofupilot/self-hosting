CREATE MIGRATION m17v2xungu5uvmlruuvltygz54q7kpnmqvxn4kqfao43ygbw3pcnia
    ONTO m1wwolab7fnxbmmolgsbvp2sfyqdu5j6jt6r3s3k6g5u45oe45ip7a
{
  ALTER TYPE default::Upload {
      ALTER LINK organization {
          SET default := ((GLOBAL default::userCurrent).organization);
          SET readonly := true;
          SET OWNED;
          SET TYPE default::Organization;
      };
  };
};
