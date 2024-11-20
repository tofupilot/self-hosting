CREATE MIGRATION m1hwu4nonwqqa2cmph6dhb57i6gvemlpocvl3ahoesyit6ahmx5sza
    ONTO m12pca645gw2tort2kmbaxqftdya6uhpyb564cjmkb2djes4gzlkwa
{
  ALTER TYPE default::PrimitiveProperty {
      DROP INDEX ON (.createdAt);
  };
  ALTER TYPE default::Primitive {
      DROP INDEX ON (.createdAt);
  };
};
