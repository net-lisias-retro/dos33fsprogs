gr_offsets:
	.word	$400,$480,$500,$580,$600,$680,$700,$780
	.word	$428,$4a8,$528,$5a8,$628,$6a8,$728,$7a8
	.word	$450,$4d0,$550,$5d0,$650,$6d0,$750,$7d0
gr_offsets_end:

.assert         >gr_offsets = >gr_offsets_end, error, "gr_offsets crosses page"
