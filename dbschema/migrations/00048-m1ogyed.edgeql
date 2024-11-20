CREATE MIGRATION m1ogyedihbs7ehhwgarluovax5lq76a6ot3awe4lqk5v3b7cndflva
    ONTO m1exmn4pqyf3zschyb5haurpspw6qnyljjbvlbjzpscy3ejflqcw2q
{
  ALTER TYPE activity::Activity {
      ALTER LINK actor {
          ON TARGET DELETE DELETE SOURCE;
      };
  };
};
