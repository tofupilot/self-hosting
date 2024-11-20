CREATE MIGRATION m1omdwbkiewqy4d3424x3g3lo6y76jzi6qt5i7tapn35rxtkki2pcq
    ONTO m1iiac67doykfvg7jmxtomvntujdr3c4ne4m6jisxt4iv7zfdir5nq
{
  CREATE TYPE default::Invitation EXTENDING default::PrimitiveProperty {
      CREATE REQUIRED PROPERTY email: std::str {
          CREATE CONSTRAINT std::exclusive;
      };
      CREATE PROPERTY name: std::str;
  };
};
