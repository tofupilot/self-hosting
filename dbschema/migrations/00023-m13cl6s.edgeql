CREATE MIGRATION m13cl6sgpknrvzb4tuaitcladesntbtwxrbatbbubdcosbupnsvf4q
    ONTO m1nfhzcxxy4q4q5bvhzaz2ts64lovrv3rmoeuitrdlb4e435wdby5a
{
  ALTER TYPE default::Primitive {
      CREATE LINK template -> default::Primitive;
      CREATE MULTI LINK instances := (.<template[IS default::Primitive]);
  };
  CREATE TYPE default::ActionTemplate EXTENDING default::Primitive;
  ALTER SCALAR TYPE default::PrimitiveNamespace EXTENDING enum<Product, Requirement, Issue, Action, ActionTemplate>;
};
