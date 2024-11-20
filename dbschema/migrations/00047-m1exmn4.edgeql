CREATE MIGRATION m1exmn4pqyf3zschyb5haurpspw6qnyljjbvlbjzpscy3ejflqcw2q
    ONTO m1iqgakufiykh3osqugwlwq3ptsbc373h2enrecuwv366pylcuspfa
{
  ALTER TYPE default::User {
      ALTER ACCESS POLICY super_admin_access ALLOW SELECT, DELETE;
  };
};
