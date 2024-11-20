CREATE MIGRATION m1w7jry2uhozos62s5rmnxfvrmc3tt4usqow6wvm2q3ostom6pypnq
    ONTO m1tjasa6dnrbixz7pts4wfquksiknwgjeg4roouqjcjnodowcuk7kq
{
  ALTER TYPE activity::Activity {
      DROP ACCESS POLICY IAllowUserToInsertItsActivity;
  };
  ALTER TYPE activity::Activity {
      CREATE ACCESS POLICY IAllowUserToInsertItsActivityAndSelectItForDebouncing
          ALLOW SELECT, INSERT USING ((GLOBAL default::currentUserId ?= .actor.id));
  };
};
