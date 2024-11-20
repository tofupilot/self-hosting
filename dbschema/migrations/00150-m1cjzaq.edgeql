CREATE MIGRATION m1cjzaqiohmfc5ncuayjmnk3ocmn2g7dwrmfchorf5ipftmngtuqma
    ONTO m15xyolwncvhlyelmhjlt3djlk4flgiom4m3phljjwywrfz7kzltva
{
  CREATE TYPE activity::ParentChange EXTENDING activity::PrimitivePropertyChange {
      CREATE LINK new: default::Primitive {
          ON TARGET DELETE DELETE SOURCE;
          SET readonly := true;
      };
      CREATE LINK old: default::Primitive {
          ON TARGET DELETE DELETE SOURCE;
          SET readonly := true;
      };
  };
};
