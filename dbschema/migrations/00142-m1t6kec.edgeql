CREATE MIGRATION m1t6kecldtl2nuk263giobem3fmuiyz4vvkz2tarzheibo4p42vcgq
    ONTO m1yvdjwjwgyjqncfflhrvpj4gajplvitjem7wqchpxv33yg5bqolha
{
  ALTER TYPE default::Primitive {
      ALTER PROPERTY estimatedTime {
          RENAME TO duration;
      };
  };
};
