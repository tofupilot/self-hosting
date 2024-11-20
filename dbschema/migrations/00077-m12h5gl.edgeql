CREATE MIGRATION m12h5gl6eatghygmbi5hejewnjdxzxawcximtdibzzgnj7fotyn5xa
    ONTO m15nsk5wv2kwwjlv4kiupmt5pzfdefkqhuloxepqjgvzxapblbaila
{
  ALTER TYPE default::Primitive {
      ALTER ACCESS POLICY IAllowTiptapServerToUpdate ALLOW SELECT, UPDATE;
  };
};
