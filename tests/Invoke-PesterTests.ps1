#!/usr/bin/env pwsh
# Copyright (c) AVEVA.
# SPDX-License-Identifier: MIT
#Requires -Version 7.0

$result = Invoke-Pester -Path $PSScriptRoot -TagFilter @('Unit') -Output Detailed -PassThru
exit $result.FailedCount
