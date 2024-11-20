CREATE MIGRATION m145uhzmfv33olzzojsi3j72epvmzq2d4234eyxvbbmmpjfichoc6q
    ONTO m1xk7ur4wf6p5ier4ae2e5f45inp6inywazti2da4ivrwaxnvuk7ma
{
  ALTER TYPE default::User {
      CREATE ACCESS POLICY IAllowSuperAdminToSelectUserForAnalytics
          ALLOW SELECT USING (((GLOBAL default::currentUser).superAdmin ?? false));
  };
};
