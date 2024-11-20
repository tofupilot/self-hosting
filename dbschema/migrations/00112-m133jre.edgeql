CREATE MIGRATION m133jrexohrufdrfgiqqa4jfsnpkd7a7gpihpkxkk5hzgsme4fz42a
    ONTO m1ujxiwyi2ovtjh3tapgjmmqpirblqenfb3f5s3sy73uu3mggh6qra
{
  ALTER TYPE default::Project {
      CREATE MULTI LINK views := (.<projects[IS view::View]);
  };
};
