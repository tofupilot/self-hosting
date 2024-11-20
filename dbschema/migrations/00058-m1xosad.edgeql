CREATE MIGRATION m1xosadc5c3hmg3ea3zbewpktcdinp7sptrjaqpo3msvprpl6alc7q
    ONTO m1wa5dxw3mn4i6nmppcfqxhigpwp4iodykesubu7wtdonwtcsuwt6q
{
  CREATE ABSTRACT TYPE activity::PrimitivePropertyChange EXTENDING activity::Activity {
      CREATE REQUIRED LINK primitive -> default::Primitive {
          ON TARGET DELETE DELETE SOURCE;
          SET readonly := true;
      };
      CREATE ACCESS POLICY IAllowIfUserInSameOrganizationThanPrimitive
          ALLOW SELECT USING (((GLOBAL default::currentUser IN .primitive.organization.users) ?? false));
  };
};
