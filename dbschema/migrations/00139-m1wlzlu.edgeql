CREATE MIGRATION m1wlzluzff6nt264zv2tkkwsyw457z3lrtaxcklnqiw7zgytlomepa
    ONTO m1w2nfu7v7e3zhfud2pu6biypqrbth7w3r6uupkn7vykq6x6qri4da
{
  ALTER TYPE default::PrimitiveProperty {
      ALTER LINK createdBy {
          SET default := ((GLOBAL default::currentUser ?? GLOBAL default::apiUser));
      };
  };
  ALTER TYPE default::Primitive {
      ALTER LINK createdBy {
          SET default := ((GLOBAL default::currentUser ?? GLOBAL default::apiUser));
      };
  };
  ALTER TYPE default::Organization {
      ALTER LINK createdBy {
          SET default := ((GLOBAL default::currentUser ?? GLOBAL default::apiUser));
      };
  };
};
