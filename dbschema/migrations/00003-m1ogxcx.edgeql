CREATE MIGRATION m1ogxcxhtccjfqqsb3draorefr7a4llk66wcyafpsrewjioxyspi4a
    ONTO m1p2qpynecmzgo6xfirc7jsyn6gspowguzaxjcn4umq3w6nutvzqkq
{
  ALTER TYPE default::Project {
      CREATE MULTI LINK primitives := (.<projects[IS default::Primitive]);
  };
};
