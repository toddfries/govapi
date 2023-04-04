use ExtUtils::MakeMaker;
WriteMakefile
(
  'NAME' => 'Gov::Data',
  'VERSION_FROM' => 'lib/Gov/Data.pm',
  'PREREQ_PM' => {
                   'libwww' => '6.68',
                   'JSON' => '4.10',
		   'XML::Simple' => '2.25',
                 },
  'INSTALLDIRS' => 'site',
  'EXE_FILES' => [],
  'PL_FILES' => {}
)
;
