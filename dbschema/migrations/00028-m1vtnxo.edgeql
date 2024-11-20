CREATE MIGRATION m1vtnxowui6kmwnpfq3y3r6fkb2ofabn3my3bg6xmmfnqdueke55aa
    ONTO m1txa7ndhylpfdmpbzlnink43ig3ulxzrbgadys6qujne7z44swg6q
{
  ALTER TYPE default::Primitive {
      ALTER LINK template {
          ON TARGET DELETE ALLOW;
      };
  };
};
