CREATE MIGRATION m16amejl5udswfop44zfichofeqifwigqcbjk4fu3h6sxbo3bdr4ea
    ONTO m1bzjuj45jfkudcq6tylt2zmbviyv2aggungzftb4qfl4syxxq7yka
{
  ALTER TYPE design::Component {
      DROP PROPERTY numberOfParents;
  };
  ALTER TYPE design::DesignInstance {
      ALTER LINK revision {
          ON SOURCE DELETE DELETE TARGET IF ORPHAN;
      };
  };
};
