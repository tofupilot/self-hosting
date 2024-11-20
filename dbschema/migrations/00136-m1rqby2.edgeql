CREATE MIGRATION m1rqby2yrgusgzwjjck7mxwntf3pwrtawrpatr3f3ohddmz5pdpfsa
    ONTO m1t7gfcq6y4gaxpl7xjdlaxztanwdjtk6hfp2nx46epulfqnkryzaq
{
  CREATE TYPE activity::CategoryChange EXTENDING activity::PrimitivePropertyChange {
      CREATE LINK new: default::Category {
          ON TARGET DELETE DELETE SOURCE;
          SET readonly := true;
      };
      CREATE LINK old: default::Category {
          ON TARGET DELETE DELETE SOURCE;
          SET readonly := true;
      };
  };
};
