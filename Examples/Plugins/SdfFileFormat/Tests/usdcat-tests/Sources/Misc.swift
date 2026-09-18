//===----------------------------------------------------------------------===//
// This source file is part of github.com/apple/SwiftUsd
//
// Copyright © 2025 Apple Inc. and the SwiftUsd project authors.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//  https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// SPDX-License-Identifier: Apache-2.0
//===----------------------------------------------------------------------===//

import Foundation

func resourcesURL() -> URL {
    URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent().deletingLastPathComponent()
        .appendingPathComponent("Resources")
}

func computeKnownInvalidOpenUSDFiles() -> [String] {
    [
        // These are intentionally malformed, to check that Sdf parsing
        // rejects invalid files
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/03_bad_file.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/05_bad_file.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/08_bad_file.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/09_bad_type.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/10_bad_value.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/12_bad_value.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/13_bad_value.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/14_bad_value.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/15_bad_list.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/16_bad_list.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/21_bad_newline1.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/22_bad_newline2.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/23_bad_newline3.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/24_bad_newline4.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/25_bad_newline5.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/26_bad_newline6.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/27_bad_newline7.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/28_bad_newline8.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/29_bad_newline9.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/30_bad_specifier.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/33_bad_relationship_duplicate_target.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/34_bad_relationship_duplicate_target_attr.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/42_bad_noNewlineBetweenComps.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/49_bad_list.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/50_bad_primPath.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/52_bad_attr.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/53_bad_typeName.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/54_bad_value.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/55_bad_value.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/55_bad_value_oldtypes.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/56_bad_value.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/56_bad_value_oldtypes.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/57_bad_relListEditing.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/58_bad_relListEditing.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/59_bad_connectListEditing.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/60_bad_groupListEditing.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/61_bad_primName.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/64_bad_boolPrimInstantiate.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/66_bad_attrVariability.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/69_bad_list.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/70_bad_list.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/80_bad_hidden.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/82_bad_tuple_dimensions1_oldtypes.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/82_bad_tuple_dimensions1.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/83_bad_tuple_dimensions2.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/83_bad_tuple_dimensions2_oldtypes.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/84_bad_tuple_dimensions3_oldtypes.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/84_bad_tuple_dimensions3.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/85_bad_tuple_dimensions4.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/85_bad_tuple_dimensions4_oldtypes.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/86_bad_tuple_dimensions5.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/89_bad_attribute_displayUnit.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/90_bad_dupePrim.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/91_bad_valueType.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/92_bad_variantSelectionType.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/94_bad_hiddenAttr.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/95_bad_hiddenRel.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/96_bad_valueType.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/96_bad_valueType_oldtypes.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/97_bad_valueType.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/98_bad_valueType.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/99_bad_typeNameChange.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/100_bad_roleNameChange.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/103_bad_attributeVariability.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/108_bad_inheritPath.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/114_bad_prefix_metadata.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/117_bad_permission_metadata.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/118_bad_permission_metadata_2.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/119_bad_permission_metadata_3.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/baseline/120_sub_attribute_relations.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/124_badwrite_marker_names.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/133_bad_reference.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/140_bad_relocates_paths_1.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/141_bad_relocates_paths_2.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/142_bad_relocates_paths_3.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/143_bad_relocates_formatting_1.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/144_bad_relocates_formatting_2.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/145_bad_relocates_formatting_3.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/146_bad_relocates_formatting_4.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/147_bad_relocates_formatting_5.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/150_bad_kind_metadata_1.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/153_bad_payloads.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/155_bad_relationship_noLoadHint.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/160_bad_variant_name1.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/161_bad_variant_name2.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/162_bad_variant_selection1.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/163_bad_variant_selection2.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/177_bad_empty_lists.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/179_bad_shaped_attr_dimensions1_oldtypes.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/179_bad_shaped_attr_dimensions1.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/181_bad_variant_in_connection.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/182_bad_variant_in_relationship.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/186_bad_prefix_substitution_key.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/194_bad_customLayerData_metadata.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/baseline/194_bad_customLayerData_metadata.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/197_bad_colorConfiguration_metadata.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/199_bad_colorSpace_metadata.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/200_bad_emptyFile.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/205_bad_assetPaths.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/206_bad_escaped_string1.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/207_bad_escaped_string2.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/208_bad_escaped_string3.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/209_bad_escaped_string4.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/211_bad_authored_opaque_attributes.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/212_bad_variant_in_reference_path.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/213_bad_variant_in_payload_path.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/214_bad_variant_in_inherits_path.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/215_bad_variant_in_specializes_path.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/216_bad_variant_in_relocates_path.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/218_utf8_bad_identifier.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/219_utf8_bad_type_name.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/221_bad_spline_type.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/223_bad_spline_post_shaping_spacing.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/229_bad_spline_extrap_loop_boundary.usda",
        
        // This file claims to test the __END__ facility that stops the parser from proceeding,
        // but usdcat fails on it. Maybe it's old behavior that was removed?
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/07_end.usda",
        
        // Malformed files
        "pxr/usd/sdf/testenv/testSdfTargetFileFormat.testenv/anyCookie.usda",
        "pxr/usd/sdf/testenv/testSdfTargetFileFormat.testenv/badCookie.usda",
        "pxr/usd/sdf/testenv/testSdfTargetFileFormat.testenv/goodCookie.usda",
        "pxr/usd/sdf/testenv/testSdfUsdcMalformed/bad_overflow_size.usdc",
        "pxr/usd/sdf/testenv/testSdfUsdcMalformed/bad_str_oversize.usdc",
        "pxr/usd/sdf/testenv/testSdfUsdcMalformed/bad_oversize_zerocopy.usdc",
        "pxr/usd/sdf/testenv/testSdfUsdcMalformed/bad_moderate_oversize.usdc",
        "pxr/usd/sdf/testenv/testSdfUsdcInvalidPrimChildren.testenv/duplicate_prim_children.usdc",
        "pxr/usd/sdf/testenv/testSdfUsdcInvalidPrimChildren.testenv/root.usdc",
        
        // TODO: Consider whether we should suppress e.g. relocation errors so we can losslessly roundtrip
        // this cattable but illegal file
        "pxr/usd/pcp/testenv/testPcpMuseum_ErrorOpinionAtRelocationSource.testenv/ErrorOpinionAtRelocationSource/root.usda",
        
        // Can't be catted due to invalid relocates
        "pxr/usd/pcp/testenv/testPcpMuseum_ErrorRelocateWithVariantSelection.testenv/ErrorRelocateWithVariantSelection/root.usda",

        // Invalid USDC file
        "pxr/usd/usd/testenv/testUsdReadOutOfBounds/corrupt.usd",
        "pxr/usd/usd/testenv/testUsdUsdcBugGHSA02.testenv/root.usdc",
        // Invalid USDZ files
        "pxr/usd/usd/testenv/testUsdUsdzBugGHSA01.testenv/root.usdz",
        "pxr/usdValidation/bin/usdchecker/testenv/testUsdChecker/bad/alembic.usdz",
        "pxr/usd/usd/testenv/testUsdUsdzFileFormat/first_file_not_usd.usdz",
        "pxr/usd/sdf/testenv/testSdfZipFile.testenv/test_reader.usdz",
        
        // Bad header, probably a typo not caught due to being for doxygen
        "pxr/usd/usdRender/doxygen/renderSettings.usda",

        // Invalid USDA file
        "pxr/usd/pcp/testenv/testPcpMuseum_SubrootReferenceAndVariants.testenv/SubrootReferenceAndVariants/root.usda",
        
        // Invalid USDA file
        "pxr/usd/usd/testenv/testUsdBug119633.testenv/ref.usda",
        
        // TODO: This uses `15.999999995559108` as a time sample key, which we seem to be dropping due to
        // insufficient precision?
        "pxr/usd/usd/testenv/testUsdValueClips/flatten/flat.usda",
        
        // TODO: Reenable these after patching rapidjson to recognize lowercase `inf`
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/31_attribute_values.usda",
        "pxr/usd/pcp/testenv/testPcpMuseum_BasicVariantWithConnections.testenv/BasicVariantWithConnections/camera_perspective.usda",
        "pxr/usd/usdPhysics/generatedSchema.usda",
        "pxr/usd/usdPhysics/schema.usda",
        "pxr/usdImaging/bin/testusdview/testenv/testUsdviewInfGeom/infGeom.usda",
        "pxr/usd/pcp/testenv/testPcpDependencies.testenv/BasicVariantWithConnections/camera_perspective.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/31_attribute_values_oldtypes.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/baseline/31_attribute_values_oldtypes.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/baseline/31_attribute_values.usda",
        
        // Malformed file
        "pxr/usdImaging/bin/testusdview/testenv/testUsdviewFileArguments/invalidSyntax.usda",
        
        // This file is malformed due to what is probably an unintentional typo
        "pxr/exec/exec/testenv/testExecComputationRegistration/resources/schema.usda",
        
        // usdcat doesn't detect the file format, though these files would be a valid .usda file with that extension
        "extras/usd/examples/usdRecursivePayloadsExample/cone.usdrecursivepayloadsexample",
        "extras/usd/examples/usdRecursivePayloadsExample/sphere.usdrecursivepayloadsexample",
        "extras/usd/examples/usdRecursivePayloadsExample/testenv/testUsdRecursivePayloadsExample/sphere.usdrecursivepayloadsexample",
        "extras/usd/examples/usdRecursivePayloadsExample/testenv/testUsdRecursivePayloadsExample/cone.usdrecursivepayloadsexample",
        
        // Running usdcat on these files produces files that usdcat can't open (quotes are dropped on path expressions in customData dictionaries),
        // which is a bug in OpenUSD. Skip for now. https://github.com/PixarAnimationStudios/OpenUSD/issues/4182
        "pxr/usd/usd/testenv/testUsdNamespaceEditorPathExpressionFixup/basic/sub1.usda",
        "pxr/usd/usd/testenv/testUsdNamespaceEditorPathExpressionFixup/basic/root.usda",
        "pxr/usd/usd/testenv/testUsdNamespaceEditorPathExpressionFixup/basic/sub2.usda",
        
        // Files that use VtArrayEdit
        "pxr/usd/usd/testenv/testUsdFlatten/root.usd",
        "pxr/usd/usd/testenv/testUsdValueClips/arrayEdits/root.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/227_arrayEdits.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/baseline/227_arrayEdits.usda",
        "pxr/usd/usd/testenv/testUsdValueClips/arrayEdits/clip.usda",
        
        // Completely empty file (0 bytes, not an empty usda file)
        "pxr/usd/usdUtils/testenv/testUsdUtilsDependencies/computeAllDependenciesInvalidPayload/invalid.usd",
        
        // usdcat fails on this file, not sure why
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/164_attr_mappers.usda",
        
        // usdcat fails on this file, maybe inherits used to support variant set selections?
        "pxr/usd/pcp/testenv/testPcpMuseum_BasicInherits.testenv/BasicInherits/root.usda",
        
        // Empty variants in metadata are usdcatted as empty metadata, which disappears when usdcatted _again_,
        // i.e. a single usdcat does not produce a fixed point as required by this usddiff test.
        // Technically maybe a very minor OpenUSD formatting bug? Skip for now
        "pxr/usd/pcp/testenv/testPcpRegressionBugs_bug92955.testenv/bug92955/root.usda",

        // Contains illegal Unicode sequences
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/baseline/46_weirdStringContent.usda",
        "pxr/usd/sdf/testenv/testSdfParsing.testenv/46_weirdStringContent.usda",
        
        
        
        // From https://dpel.aswf.io/4004-moore-lane/:
        // These files contain `nan`s which can't currently be roundtripped, same as `inf`
        // TODO: Fix nan and inf roundtripping
        "Intel_mooreLane_v1_2_0/Intel_mooreLane/USD/4004MooreLane_III_03_ASFW.usd",
        "Intel_mooreLane_v1_2_0/Intel_mooreLane/USD/4004MooreLane_III_03_ASWF.usd",
        "Intel_mooreLane_v1_2_0/Intel_mooreLane/USD/MooreLane_ASWF_0621_fullComposition.usda",
        
        // From https://dpel.aswf.io/alab/:
        // These files are 880MB to multiple GB as .usdc files, and trying to
        // run the tests on them caused my machine to crash (twice) due to
        // running out of memory. They're probably fine, just very large.
        "ALab-2.2.0/ALab/baked_procedurals/payload/stoat_body_main.1004.usd",
        "ALab-2.2.0/ALab/baked_procedurals/payload/stoat_body_main.1014.usd",
        "ALab-2.2.0/ALab/baked_procedurals/payload/stoat_body_main.1054.usd",
        "ALab-2.2.0/ALab/baked_procedurals/payload/stoat_body_main.1044.usd",
        "ALab-2.2.0/ALab/baked_procedurals/clip.topology.usd",
        "ALab-2.2.0/ALab/baked_procedurals/payload/stoat_body_main.1024.usd",
        "ALab-2.2.0/ALab/baked_procedurals/payload/stoat_body_main.1034.usd",
        "ALab-2.2.0/ALab/baked_procedurals/stoat.usd",
        "ALab-2.2.0/ALab/baked_procedurals/uvs.usd",
    ]
}

