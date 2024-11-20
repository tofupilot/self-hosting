CREATE MIGRATION m1bzmswuoz3gxphfhkdgnxe4zrdo4vbuiz5ogptnqoj4kxdy7joy2q
    ONTO m12h5gl6eatghygmbi5hejewnjdxzxawcximtdibzzgnj7fotyn5xa
{
  ALTER GLOBAL default::isTiptapServer RESET default;
  ALTER TYPE default::Primitive {
      CREATE ACCESS POLICY IAllowSuperAdminToSelectForAnalytics
          ALLOW SELECT USING (((GLOBAL default::currentUser).superAdmin ?? false));
  };
};
